defmodule TestSubscriber do
  use Shout

  subscribe(Module, :some_event, &String.split/2)
  subscribe(Enum, :another_event, &String.split/1)
end
