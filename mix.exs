defmodule Thrifter.Mixfile do
  use Mix.Project

  def project do
    [app: :thrifter,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :uuid]]
  end

  defp deps do
    [
      {:riffed, github: "renderedtext/riffed", ref: "origin/master"},
      {:ex_spec, "~> 1.0", only: :test},
      {:uuid, "~> 1.1"}
    ]
  end
end
