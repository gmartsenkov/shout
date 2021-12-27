defmodule EmailService do
  @moduledoc false
  use TestSubscriber.Publisher

  def notify_user(_user) do
    send(self(), {:event, :notify_user})
    broadcast(:email_sent, :ok)
  end

  def check_email(:ok) do
    send(self(), {:event, :check_email})
  end
end
