defmodule Shout.Subscription do
  @moduledoc """
  A struct to represent a subscription.
  """
  defstruct [:from, :event, :to, async: false]

  @type t :: %Shout.Subscription{
          from: module(),
          event: String.t(),
          to: function(),
          async: boolean()
        }
end
