defmodule Shout.MixProject do
  use Mix.Project

  def project do
    [
      app: :shout,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Shout.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:assertions, "~> 0.19.0", only: :test}
    ]
  end
end
