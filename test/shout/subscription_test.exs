defmodule Shout.SubscriptionTest do
  use ExUnit.Case

  alias Shout.Subscription

  describe "storage_format" do
    test "returns the correct string" do
      sub = %Subscription{from: Module, event: :some_event, to: &String.split/2}
      assert Subscription.storage_format(sub) == {{Module, :some_event}, &String.split/2}
    end
  end
end
