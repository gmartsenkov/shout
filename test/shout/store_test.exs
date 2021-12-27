defmodule Shout.StoreTest do
  use ExUnit.Case
  require Assertions
  import Assertions, only: [assert_lists_equal: 2]

  alias Shout.Store

  setup do
    {:ok, pid} = Store.start_link([])

    [
      store: pid,
      subscription: %Shout.Subscription{from: Module, event: :some_event, to: &String.split/1},
      another_subscription: %Shout.Subscription{
        from: Module,
        event: :some_event,
        to: &String.split/2
      },
      yet_another_subscription: %Shout.Subscription{
        from: Module,
        event: :another_event,
        to: &String.split/1
      }
    ]
  end

  describe "init" do
    test "returns the default state" do
      assert Store.init([]) == {:ok, %{subscriptions: []}}
    end

    test "with compile time subscriptions", context do
      subs = [context.subscription]

      assert Store.init(compile_time_subscriptions: subs) ==
               {:ok, %{subscriptions: [context.subscription]}}
    end
  end

  describe "register_subscription" do
    test "adds the subscription to the genserver state", context do
      assert Store.subscriptions(context.store) == []
      :ok = Store.register_subscription(context.subscription, context.store)

      assert_lists_equal(
        Store.subscriptions(context.store),
        [context.subscription]
      )

      :ok = Store.register_subscription(context.another_subscription, context.store)

      assert_lists_equal(
        Store.subscriptions(context.store),
        [context.subscription, context.another_subscription]
      )

      Store.register_subscription(context.subscription, context.store)

      assert_lists_equal(
        Store.subscriptions(context.store),
        [context.subscription, context.another_subscription]
      )
    end

    test "doesn't create a duplicate", context do
      :ok = Store.register_subscription(context.subscription, context.store)
      assert_lists_equal(Store.subscriptions(context.store), [context.subscription])
      :exists = Store.register_subscription(context.subscription, context.store)
      assert_lists_equal(Store.subscriptions(context.store), [context.subscription])
    end
  end

  describe "unregister_subscription" do
    test "calls the correct genserver message", context do
      :ok = Store.register_subscription(context.subscription, context.store)
      :ok = Store.register_subscription(context.another_subscription, context.store)
      :ok = Store.register_subscription(context.yet_another_subscription, context.store)

      assert_lists_equal(
        Store.subscriptions(context.store),
        [context.subscription, context.another_subscription, context.yet_another_subscription]
      )

      assert Store.unregister_subscription(context.subscription, context.store)

      assert_lists_equal(
        Store.subscriptions(context.store),
        [context.yet_another_subscription]
      )

      assert Store.unregister_subscription(context.yet_another_subscription, context.store)
      assert_lists_equal(Store.subscriptions(context.store), [])
    end
  end

  describe "#subscriptions" do
    test "returns the correct subscriptions", context do
      :ok = Store.register_subscription(context.subscription, context.store)
      :ok = Store.register_subscription(context.another_subscription, context.store)
      :ok = Store.register_subscription(%{context.subscription | event: :another}, context.store)
      :ok = Store.register_subscription(%{context.subscription | from: List}, context.store)

      assert_lists_equal(
        Store.subscriptions(context.store),
        [
          %Shout.Subscription{event: :some_event, from: Module, to: &String.split/1},
          %Shout.Subscription{event: :some_event, from: Module, to: &String.split/2},
          %Shout.Subscription{event: :another, from: Module, to: &String.split/1},
          %Shout.Subscription{event: :some_event, from: List, to: &String.split/1}
        ]
      )

      assert_lists_equal(
        Store.subscriptions(Module, :some_event, context.store),
        [
          %Shout.Subscription{event: :some_event, from: Module, to: &String.split/1},
          %Shout.Subscription{event: :some_event, from: Module, to: &String.split/2}
        ]
      )
    end
  end
end
