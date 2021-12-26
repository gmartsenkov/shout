defmodule TestSubscriber do
  use Shout.Router

  subscribe(Module, :some_event, with: &String.split/2)
  subscribe(Enum, :another_event, with: &String.split/1)
  subscribe(UserService, :user_created, with: &EmailService.notify_user/1)
end
