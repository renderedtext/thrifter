defmodule Mix.Tasks.Thrifter.All do
  use Mix.Task

  @shortdoc "Generate Thrift Client for every supported language"

  def run(args) do
    Mix.Tasks.Thrifter.Ruby.run(args)
    Mix.Tasks.Thrifter.Elixir.run(args)
  end
end
