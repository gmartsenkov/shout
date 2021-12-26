defmodule Shout.Router do
  alias Shout.Subscription

  @dialyzer {:no_return, {:subscribe, 1}}

  defmodule CompileTimeSubs do
    defmacro __before_compile__(_env) do
      quote do
        def compile_time_subscriptions() do
          @compile_time_subscriptions
        end
      end
    end
  end

  defmacro __using__(_env) do
    quote do
      Module.register_attribute(__MODULE__, :compile_time_subscriptions, accumulate: true)

      @before_compile CompileTimeSubs

      import Shout.Router

      defdelegate subscribe(opts), to: Shout.Router

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

  defmacro subscribe(opts) do
    quote bind_quoted: [opts: opts] do
      from = Keyword.get(opts, :to)
      event = Keyword.get(opts, :for)
      to = Keyword.get(opts, :with)

      subscription = %Subscription{from: from, event: event, to: to}

      case __ENV__ do
        %{function: nil} ->
          Module.put_attribute(__MODULE__, :compile_time_subscriptions, subscription)

        _else ->
          Shout.Store.register_subscription(subscription, __MODULE__)
      end
    end
  end
end
