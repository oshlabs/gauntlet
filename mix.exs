defmodule Gauntlet.MixProject do
  use Mix.Project

  def project do
    [
      app: :gauntlet,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      description: "Execution-graded benchmark of LLM capability at Elixir",
      package: [
        licenses: ["MIT"],
        links: %{}
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :eex],
      mod: {Gauntlet.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:req_llm, "~> 1.5"},
      {:jason, "~> 1.4"},
      {:credo, "~> 1.7", runtime: false}
    ]
  end
end
