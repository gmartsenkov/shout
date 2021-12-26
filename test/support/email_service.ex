defmodule EmailService do
  use TestSubscriber.Publisher

  def notify_user(_user) do
    IO.inspect("send email")
    broadcast(:email_sent, :ok)
  end
end
