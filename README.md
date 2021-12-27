# Shout
  A small library that provides Elixir modules with subscribe/publish functionality.
  - Separate core business logic from external concerns
  - Publish events synchronously or asynchronously

![](https://github.com/gmartsenkov/shout/workflows/Elixir%20CI/badge.svg) [![codecov](https://codecov.io/gh/gmartsenkov/shout/branch/master/graph/badge.svg?token=WLC3606GQR)](https://codecov.io/gh/gmartsenkov/shout)
  # Usage

  Create your router, usually one per app but can be many. You'll define all the subscriptions in there. It's simply a GenServer that will keep track of subscriptions and allow you to add or remove subscriptions. **(Don't forget to add it to your supervision tree)**

  ### Router
  ```elixir
  defmodule MyApp.Events do
    use Shout.Router

    subscribe(MyApp.Users.Create, :user_created, to: &MyApp.Emails.welcome_email/1)

    # Runs it asynchronously (uses Kernel.spawn/1)
    subscribe(MyApp.Users.Updated, :user_updated, to: &MyApp.Service.custom_task/1, async: true)
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

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `shout` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:shout, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/shout>.

