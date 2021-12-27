defmodule UserService do
  import TestSubscriber.Publisher

  def create_user do
    send(self(), {:event, :user_created})
    broadcast(:user_created, %{name: "Jon Snow"})
  end
end
