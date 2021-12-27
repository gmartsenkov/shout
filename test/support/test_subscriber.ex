defmodule TestSubscriber do
  use Shout.Router

  subscribe(UserService, :user_created, with: &EmailService.notify_user/1)
  subscribe(EmailService, :email_sent, with: &EmailService.check_email/1)
end
