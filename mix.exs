defmodule Shout.MixProject do
  use Mix.Project

  @source_url "https://github.com/gmartsenkov/shout"

  def project do
    [
      app: :shout,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      name: "Shout",
      package: package(),
      description:
        "A small library that provides Elixir modules with subscribe/publish functionality.",
      source_url: @source_url,
      docs: [
        # The main page in the docs
        main: "Shout",
        extras: ["README.md"]
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:assertions, "~> 0.19.0", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: [:test]}
    ]
  end

  defp package do
    [
      maintainers: ["Georgi Martsenkov"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp aliases do
    [
      test: ["test", "credo --strict"]
    ]
  end
end
