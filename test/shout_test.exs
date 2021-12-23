defmodule ShoutTest do
  use ExUnit.Case
  import Assertions, only: [assert_lists_equal: 2]

  test "compile_time_subscriptions" do
    assert_lists_equal(
      Shout.compile_time_subscriptions(),
      [
        %Shout.Subscription{event: :flatten, from: List, to: &Enum.sort/1},
        %Shout.Subscription{event: :some_event, from: Module, to: &String.split/2},
        %Shout.Subscription{event: :another_event, from: Enum, to: &String.split/1}
      ]
    )
  end
end
