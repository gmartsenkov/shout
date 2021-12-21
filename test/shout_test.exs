defmodule ShoutTest do
  use ExUnit.Case
  doctest Shout

  test "greets the world" do
    assert Shout.hello() == :world
  end
end
