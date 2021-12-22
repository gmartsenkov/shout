defmodule Shout.Subscription do
  defstruct [:from, :event, :to]

  @type t :: %__MODULE__{
          from: Module.t(),
          event: String.t(),
          to: Function.t()
        }

  @spec storage_format(Shout.Subscription.t()) :: tuple()
  def storage_format(subscription) do
    {{subscription.from, subscription.event}, subscription.to}
  end
end
