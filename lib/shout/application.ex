defmodule Shout.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Shout.Store
    ]

    opts = [strategy: :one_for_one, name: Shout.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
