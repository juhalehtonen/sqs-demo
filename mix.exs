defmodule SQSDemo.MixProject do
  use Mix.Project

  def project do
    [
      app: :sqsdemo,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SQSDemo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:broadway, "~> 0.6.0"},
      {:broadway_sqs, "~> 0.6.1"},
      {:hackney, "~> 1.9"},
      {:jason, "~> 1.2"}
    ]
  end
end
