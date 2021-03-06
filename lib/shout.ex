defmodule Shout do
  @moduledoc """
  A small library that provides Elixir modules with subscribe/publish functionality.
  - Separate core business logic from external concerns
  - Publish events synchronously or asynchronously

  # Usage

  Create your router, usually one per app but can be many. You'll define all the subscriptions in there. It's simply a GenServer that will keep track of subscriptions and allow you to add or remove more. (Don't forget to add it to your supervision tree)

  ### Router
  ```elixir
  defmodule MyApp.Events do
    use Shout.Router

    subscribe(MyApp.Users.Create, :user_created, to: &MyApp.Emails.welcome_email/1)

    # Runs it asynchronously (uses Kernel.spawn/1)
    subscribe(MyApp.Users.Updated, :user_updated, to: &MyApp.Service.custom_task/1, asnyc: true)
  end
  ```
  A subscription can be added at runtime too:
  ```elixir
  MyApp.Events.subscribe(MyApp.SomeTask, :success, &MyApp.Notify.send_email/1)
  ```
  Shout will make sure there are no duplicate subscriptions.

  ### Publishing
  By default when publishing an event using `broadcast` the subscriptions will be executed synchronously.
  ```elixir
  defmodule MyApp.Users.Create do
    use MyApp.Events.Publisher

    def create(params) do
      user = User.create(params)
      broadcast(:user_created, user) # Will trigger: MyApp.Emails.welcome_email/1
    end
  end
  ```
  """
end
