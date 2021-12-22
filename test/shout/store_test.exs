defmodule Shout.StoreTest do
  use ExUnit.Case
  require Assertions
  import Assertions, only: [assert_lists_equal: 2]

  alias Shout.Store

  def random_table_name do
    for _ <- 1..10, into: "", do: <<Enum.random('0123456789abcdef')>>
  end

  setup do
    table_name = String.to_atom(random_table_name())
    {:ok, pid} = Store.start_link(name: nil, table: table_name)

    [
      table: table_name,
      store: pid,
      subscription: %Shout.Subscription{from: Module, event: :some_event, to: &String.split/1},
      another_subscription: %Shout.Subscription{
        from: Module,
        event: :some_event,
        to: &String.split/2
      }
    ]
  end

  describe "init" do
    test "it creates the correct ets table and returns the correct tuple" do
      assert :ets.whereis(:init_test) == :undefined
      assert Store.init(table: :init_test) == {:ok, :init_test}
      refute :ets.whereis(:init_test) == :undefined
    end
  end

  describe "register_subscription" do
    test "calls the correct genserver message", context do
      assert :ets.tab2list(context.table) == []

      :ok = Store.register_subscription(context.subscription, context.store)

      assert_lists_equal(
        :ets.tab2list(context.table),
        [
          {{Module, :some_event}, &String.split/1}
        ]
      )

      :ok = Store.register_subscription(context.another_subscription, context.store)

      assert_lists_equal(
        :ets.tab2list(context.table),
        [
          {{Module, :some_event}, &String.split/1},
          {{Module, :some_event}, &String.split/2}
        ]
      )

      :ok = Store.register_subscription(context.subscription, context.store)

      assert_lists_equal(
        :ets.tab2list(context.table),
        [
          {{Module, :some_event}, &String.split/1},
          {{Module, :some_event}, &String.split/2}
        ]
      )
    end
  end

  describe "unregister_subscription" do
    test "calls the correct genserver message", context do
      :ok = Store.register_subscription(context.subscription, context.store)
      :ok = Store.register_subscription(context.another_subscription, context.store)

      assert_lists_equal(
        :ets.tab2list(context.table),
        [
          {{Module, :some_event}, &String.split/1},
          {{Module, :some_event}, &String.split/2}
        ]
      )

      assert Store.unregister_subscription(context.subscription, context.store)

      assert_lists_equal(
        :ets.tab2list(context.table),
        [
          {{Module, :some_event}, &String.split/2}
        ]
      )

      assert Store.unregister_subscription(context.another_subscription, context.store)
      assert :ets.tab2list(context.table) == []
    end
  end

  describe "#subscriptions" do
    test "returns the correct subscriptions", context do
      :ok = Store.register_subscription(context.subscription, context.store)
      :ok = Store.register_subscription(context.another_subscription, context.store)
      :ok = Store.register_subscription(%{context.subscription | event: :another}, context.store)
      :ok = Store.register_subscription(%{context.subscription | from: List}, context.store)

      assert_lists_equal(
        :ets.tab2list(context.table),
        [
          {{List, :some_event}, &String.split/1},
          {{Module, :some_event}, &String.split/1},
          {{Module, :some_event}, &String.split/2},
          {{Module, :another}, &String.split/1}
        ]
      )

      assert_lists_equal(
        Store.subscriptions(Module, :some_event, context.store),
        [
          {{Module, :some_event}, &String.split/1},
          {{Module, :some_event}, &String.split/2}
        ]
      )
    end
  end
end
