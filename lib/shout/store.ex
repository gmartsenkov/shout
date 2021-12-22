defmodule Shout.Store do
  use GenServer

  alias Shout.Subscription

  @table :shout

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def subscriptions(module, event, pid \\ __MODULE__) do
    GenServer.call(pid, {:subscriptions, module, event})
  end

  def register_subscription(subscription, pid \\ __MODULE__) do
    GenServer.call(pid, {:register_subscription, subscription})
  end

  def unregister_subscription(subscription, pid \\ __MODULE__) do
    GenServer.call(pid, {:unregister_subscription, subscription})
  end

  # Server callbacks

  @impl true
  def init(opts) do
    table = Keyword.get(opts, :table, @table)
    :ets.new(table, [:duplicate_bag, :named_table, read_concurrency: true])

    {:ok, table}
  end

  @impl true
  def handle_call({:register_subscription, %Subscription{} = subscription}, _from, table) do
    formatted = Subscription.storage_format(subscription)
    match = :ets.match_object(table, formatted)
    if match == [], do: :ets.insert(table, formatted)

    {:reply, :ok, table}
  end

  @impl true
  def handle_call({:unregister_subscription, %Subscription{} = subscription}, _from, table) do
    formatted = Subscription.storage_format(subscription)
    num_of_deleted = :ets.match_delete(table, formatted)

    {:reply, num_of_deleted, table}
  end

  @impl true
  def handle_call({:subscriptions, module, event}, _from, table) do
    {
      :reply,
      :ets.match_object(table, {{module, event}, :_}),
      table
    }
  end
end
