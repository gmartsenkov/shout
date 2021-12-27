defmodule Shout.Router do
  @moduledoc """
  Use this module to setup your subscription module.
  Add it to your supervision tree, it'll start a simple GenServer and store the subscriptions.
  ```elixir
  defmodule MyApp.Events do
    use Shout.Router

    subscribe(MyApp.Users.Create, :user_created, to: &MyApp.Emails.welcome_email/1)
  end

  defmodule MyApp.Service.User do
    use MyApp.Events.Publisher

    def create(...) do
      broadcast(:user_created, %{email: "jon@snow.com"})
    end
  end

  defmodule MyApp.Emails do
    def welcome_email(%{email: email}) do
      SendEmail.to(email)
    end
  end
  ```
  """
  alias Shout.Subscription

  @dialyzer {:no_return, {:subscribe, 3}}

  defmodule CompileTimeSubs do
    @moduledoc false
    defmacro __before_compile__(_env) do
      quote do
        def compile_time_subscriptions do
          @compile_time_subscriptions
        end
      end
    end
  end

  defmacro __using__(_env) do
    router = __CALLER__.module

    quote bind_quoted: [router: router] do
      defmodule Publisher do
        defmacro __using__(_env) do
          quote do
            import Publisher
          end
        end

        defmacro broadcast(event, data) do
          caller = __CALLER__.module
          router = unquote(router)

          quote bind_quoted: [router: router, caller: caller, data: data, event: event] do
            Shout.Store.subscriptions(caller, event, router)
            |> Shout.Runner.run(data)

            data
          end
        end
      end

      Module.register_attribute(__MODULE__, :compile_time_subscriptions, accumulate: true)
      @before_compile CompileTimeSubs

      import Shout.Router

      defdelegate subscribe(from, event, opts), to: Shout.Router
      defdelegate unsubscribe(from, event), to: Shout.Router

      def start_link(opts) do
        Shout.Store.start_link(
          name: __MODULE__,
          compile_time_subscriptions: compile_time_subscriptions()
        )
      end

      def subscriptions do
        Shout.Store.subscriptions(__MODULE__)
      end

      @spec register_subscription(Shout.Subscription.t()) :: :ok | :exists
      def register_subscription(subscription) do
        Shout.Store.register_subscription(subscription, __MODULE__)
      end

      @spec unregister_subscription(Shout.Subscription.t()) :: :ok
      def unregister_subscription(subscription) do
        Shout.Store.unregister_subscription(subscription, __MODULE__)
      end
    end
  end

  defmacro subscribe(from, event, opts) do
    quote bind_quoted: [opts: opts, from: from, event: event] do
      to = Keyword.get(opts, :with)
      async = Keyword.get(opts, :async, false)

      subscription = %Subscription{from: from, event: event, to: to, async: async}

      case __ENV__ do
        %{function: nil} ->
          Module.put_attribute(__MODULE__, :compile_time_subscriptions, subscription)

        _else ->
          Shout.Store.register_subscription(subscription, __MODULE__)
      end
    end
  end

  defmacro unsubscribe(from, event) do
    quote bind_quoted: [from: from, event: event] do
      Shout.Store.unregister_subscription(
        %Subscription{from: from, event: event},
        __MODULE__
      )
    end
  end
end
