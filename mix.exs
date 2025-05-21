defmodule Trabant.MixProject do
  use Mix.Project

  def project do
    [
      app: :trabant,
      version: "0.1.1",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Trabant.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.0"},
      {:websock_adapter, "~> 0.5"},
      {:jason, "~> 1.4"},
      {:phoenix_pubsub, "~> 2.0"},
      {:websockex, "~> 0.4"}
      # {:telemetry, "~> 1.0"}
      # {:dialyxir, "~> 1.4"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
