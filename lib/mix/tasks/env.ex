defmodule Mix.Tasks.Thrifter.Env do
  use Mix.Task

  @shortdoc "Fetches Thrifter environment variables"
  @credentials_url "s3://renderedtext-secrets/thrifter/env"

  def run(_) do
    file_id = UUID.uuid1

    System.cmd("aws", ["s3", "cp", @credentials_url, file_id])

    file_id |> File.read! |> IO.puts

    File.rm(file_id)
  end
end
