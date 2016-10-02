defmodule Mix.Tasks.Thrifter.Elixir do
  use Mix.Task
  alias Thrifter.Templates
  alias Thrifter.Thrift
  alias Thrifter.Colors

  @shortdoc "Generate Thrift Elixir client"

  def run(_) do
    Mix.shell.info "\n--- Generating elixir client ---\n"

    clean_output_dir
    Thrift.generate(output: thrift_output_dir, language: "erl")
    generate_elixir_files

    Mix.shell.info "\Elixir client generated in #{Colors.green(client_dir)}\n"
  end

  defp client_dir do
    "gen/elixir-client"
  end

  def thrift_output_dir do
    "#{client_dir}/src"
  end

  defp client_name do
    Mix.Project.config[:app] |> Atom.to_string
  end

  defp clean_output_dir do
    File.rm_rf!(client_dir)
    File.mkdir_p!(client_dir)
  end

  defp generate_elixir_files do
    options = [
      client_name: client_name,
      client_module_name: Macro.camelize(client_name),
      service_name: Thrift.Erlang.service_name(thrift_output_dir),
      function_names: Thrift.Erlang.function_names(thrift_output_dir),
      structs: Thrift.Erlang.structs(thrift_output_dir),
      version: Mix.Project.config[:version]
    ]

    template_file_paths = Templates.template_files_for(:elixir)
    output_file_paths   = template_file_paths
                          |> Enum.map(&String.replace(&1, "CLIENT_NAME", client_name))
                          |> Enum.map(&String.replace(&1, "templates/elixir", client_dir))
                          |> Enum.map(&String.replace(&1, ".eex", ""))

    Mix.shell.info "\nRendering elixir files:\n"

    Enum.zip(template_file_paths, output_file_paths) |> Enum.each fn {template, output} ->
      Mix.shell.info " - #{Colors.green(output)}"

      Path.dirname(output) |> File.mkdir_p!

      File.write! output, Templates.render(template, options)
    end
  end

end
