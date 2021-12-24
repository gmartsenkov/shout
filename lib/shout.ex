defprotocol CompileTimeSubscribers do
  def compile_time_subscriptions(_)
end

defmodule Shout.Subs do
  defmacro __before_compile__(_env) do
    quote do
      def compile_time_subscriptions() do
        @compile_time_subscriptions
      end
    end
  end
end

defmodule Shout do
  alias Shout.Subscription

  @compile_subscription_apps Application.compile_env(:shout, :apps, [])

  defmacro __using__(_env) do
    quote do
      Module.register_attribute(__MODULE__, :compile_time_subscriptions, accumulate: true)

      import Shout

      @before_compile Shout.Subs

      defimpl CompileTimeSubscribers do
        def compile_time_subscriptions(_any), do: nil
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
          Shout.Store.register_subscription(subscription)
      end
    end
  end

  def compile_time_subscriptions do
    ebin_dirs = Enum.map(@compile_subscription_apps, fn app -> :code.lib_dir(app, :ebin) end)
    mods = Protocol.extract_impls(CompileTimeSubscribers, ebin_dirs)

    Enum.flat_map(mods, fn mod -> mod.compile_time_subscriptions() end)
  end
end
