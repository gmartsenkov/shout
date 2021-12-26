defmodule Shout.RouterTest do
  use ExUnit.Case
  require Assertions
  import Assertions, only: [assert_lists_equal: 2]

  test "compile_time_subscriptions" do
    assert_lists_equal(
      TestSubscriber.compile_time_subscriptions(),
      [
        %Shout.Subscription{event: :another_event, from: Enum, to: &String.split/1},
        %Shout.Subscription{event: :some_event, from: Module, to: &String.split/2}
      ]
    )
  end

  test "the router" do
    {:ok, _pid} = TestSubscriber.start_link([])

    assert_lists_equal(
      TestSubscriber.subscriptions(),
      [
        %Shout.Subscription{event: :another_event, from: Enum, to: &String.split/1},
        %Shout.Subscription{event: :some_event, from: Module, to: &String.split/2}
      ]
    )

    TestSubscriber.subscribe(to: List, for: :compact, with: &String.split/1)
  end
end
