defmodule Shout.Subscription do
  defstruct [:from, :event, :to, async: false]

  @type t :: %__MODULE__{
          from: Module.t(),
          event: String.t(),
          to: Function.t(),
          async: boolean()
        }
end
