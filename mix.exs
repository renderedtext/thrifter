defmodule Thrifter.Mixfile do
  use Mix.Project

  def project do
    [app: :thrifter,
     version: "1.1.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :uuid, :poison]]
  end

  defp deps do
    [
      {:thttpt,            git: "git@github.com:renderedtext/ex-thttpt.git"},
      {:ex_spec, "~> 1.0", only: :test},
      {:uuid, "~> 1.1"},
      {:poison, "~> 2.0"}
    ]
  end
end
