defprotocol CompileTimeSubscribers do
  def compile_time_subscriptions(_)
end

defmodule Shout do
  alias Shout.Subscription

  defmacro __using__(_env) do
	  quote do
      Module.register_attribute(__MODULE__, :compile_time_subscriptions, accumulate: true, persist: true)

      import Shout

      defimpl CompileTimeSubscribers  do
        def compile_time_subscriptions(_any), do: nil
      end

      def compile_time_subscriptions() do
        __MODULE__.module_info(:attributes)
        |> Enum.map(fn {k,v} -> if k == :compile_time_subscriptions, do: v end)
        |> Enum.reject(&is_nil/1)
        |> List.flatten()
      end
    end
  end

  defmacro subscribe(from, event, to) do
    quote do
      subscription = %Subscription{from: unquote(from), event: unquote(event), to: unquote(to)}
      case __ENV__ do
        %{function: nil} ->
          Module.put_attribute(__MODULE__, :compile_time_subscriptions, subscription)
        _else ->
          Shout.Store.register_subscription(subscription)
      end
    end
  end

  def compile_time_subscriptions do
    ebin = :code.lib_dir(:shout, :ebin)
    mods = Protocol.extract_impls(CompileTimeSubscribers, [ebin])

    Enum.flat_map(mods, fn mod -> mod.compile_time_subscriptions() end)
  end
end
