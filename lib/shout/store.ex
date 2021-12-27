defmodule Shout.Store do
  @moduledoc """
  GenServer to persist the subscriptions.
  They are stored as an array
  ```elixir
  [
    %Shout.Subscription{from: MyService, event: :created, to: &Email.notify/1},
    ...
  ]
  ```
  """
  use GenServer

  alias Shout.Subscription

  @default_state %{subscriptions: []}

  def start_link(opts) do
    gen_server_opts = Keyword.take(opts, [:name])
    GenServer.start_link(__MODULE__, opts, gen_server_opts)
  end

  def subscriptions(pid) do
    GenServer.call(pid, :subscriptions)
  end

  def subscriptions(module, event, pid) do
    GenServer.call(pid, {:subscriptions, module, event})
  end

  @spec register_subscription(Subscription.t(), pid() | module()) :: :ok | :exist
  def register_subscription(subscription, pid) do
    GenServer.call(pid, {:register_subscription, subscription})
  end

  @spec unregister_subscription(Subscription.t(), pid() | module()) :: :ok
  def unregister_subscription(subscription, pid) do
    GenServer.call(pid, {:unregister_subscription, subscription})
  end

  # Server callbacks

  @impl true
  def init(opts) do
    subscriptions = Keyword.get(opts, :compile_time_subscriptions, [])
    {:ok, %{@default_state | subscriptions: subscriptions}}
  end

  @impl true
  def handle_call(
        {:register_subscription, %Subscription{} = subscription},
        _from,
        %{subscriptions: subs} = state
      ) do
    if Enum.any?(subs, &(&1 == subscription)) do
      {:reply, :exists, state}
    else
      updated_subs = subs ++ [subscription]

      {:reply, :ok, put_in(state.subscriptions, updated_subs)}
    end
  end

  @impl true
  def handle_call(
        {:unregister_subscription, %Subscription{} = subscription},
        _from,
        %{subscriptions: subs} = state
      ) do
    case match_subscriptions(subs, subscription.from, subscription.event) do
      [] ->
        {:reply, :missing, state}

      found ->
        updated_subs = subs -- found
        {:reply, :ok, put_in(state.subscriptions, updated_subs)}
    end
  end

  @impl true
  def handle_call(:subscriptions, _from, state) do
    {:reply, state.subscriptions, state}
  end

  @impl true
  def handle_call({:subscriptions, module, event}, _from, state) do
    found = match_subscriptions(state.subscriptions, module, event)

    {:reply, found, state}
  end

  defp match_subscriptions(subs, from, event) do
    Enum.filter(subs, fn sub ->
      sub.from == from && sub.event == event
    end)
  end
end
