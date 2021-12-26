defmodule TestSubscriber do
  use Shout.Router

  subscribe(to: Module, for: :some_event, with: &String.split/2)
  subscribe(to: Enum, for: :another_event, with: &String.split/1)
end
