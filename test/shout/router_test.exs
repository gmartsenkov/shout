defmodule Shout.RouterTest do
  use ExUnit.Case
  require Assertions
  import Assertions, only: [assert_lists_equal: 2]
  alias Shout.Subscription

  test "compile_time_subscriptions" do
    assert_lists_equal(
      TestSubscriber.compile_time_subscriptions(),
      [
        %Subscription{event: :email_sent, from: EmailService, to: &EmailService.check_email/1},
        %Subscription{event: :user_created, from: UserService, to: &EmailService.notify_user/1}
      ]
    )
  end

  test "the router" do
    assert_lists_equal(
      TestSubscriber.subscriptions(),
      [
        %Subscription{event: :email_sent, from: EmailService, to: &EmailService.check_email/1},
        %Subscription{event: :user_created, from: UserService, to: &EmailService.notify_user/1}
      ]
    )

    TestSubscriber.subscribe(List, :compact, with: &String.split/1, async: true)

    assert_lists_equal(
      TestSubscriber.subscriptions(),
      [
        %Subscription{event: :email_sent, from: EmailService, to: &EmailService.check_email/1},
        %Subscription{event: :user_created, from: UserService, to: &EmailService.notify_user/1},
        %Subscription{event: :compact, from: List, to: &String.split/1, async: true}
      ]
    )

    TestSubscriber.unsubscribe(List, :compact)

    assert_lists_equal(
      TestSubscriber.subscriptions(),
      [
        %Subscription{event: :email_sent, from: EmailService, to: &EmailService.check_email/1},
        %Subscription{event: :user_created, from: UserService, to: &EmailService.notify_user/1}
      ]
    )

    user = UserService.create_user()
    assert user == %{name: "Jon Snow"}

    assert_received {:event, :user_created}
    assert_received {:event, :notify_user}
    assert_received {:event, :check_email}
  end
end
