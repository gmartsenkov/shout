defmodule UserService do
  import TestSubscriber.Publisher

  def create_user do
    broadcast(:user_created, %{name: "Jon Snow"})
  end
end
