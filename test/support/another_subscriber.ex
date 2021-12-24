defmodule AnotherSubscriber do
  use Shout

  subscribe(to: List, for: :flatten, with: &Enum.sort/1)
end
