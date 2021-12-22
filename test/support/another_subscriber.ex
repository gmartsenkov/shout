defmodule AnotherSubscriber do
  use Shout

  subscribe(List, :flatten, &Enum.sort/1)
end
