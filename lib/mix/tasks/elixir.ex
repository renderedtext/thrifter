defmodule Mix.Tasks.Thrifter.Elixir do
  use Mix.Task
  alias Thrifter.Templates
  alias Thrifter.Thrift
  alias Thrifter.Colors
  alias Thrifter.Directory

  @shortdoc "Generate Thrift Elixir client"

  def client_dir, do: "gen/elixir-client"
  def thrift_output_dir, do: "#{client_dir}/src"
  def client_name, do: Mix.Project.config[:app] |> Atom.to_string

  def run(_) do
    Mix.shell.info "Generating elixir client"
    Mix.shell.info "------------------------"

    Directory.clean(client_dir)
    Thrift.generate(output: thrift_output_dir, language: "erl")
    generate_elixir_files

    Mix.shell.info "\nElixir client generated in #{Colors.green(client_dir)}\n"
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

    template_paths = Templates.template_files_for(:elixir)
    output_paths   = output_file_paths(template_paths)

    Templates.render(template_paths, output_paths, options)
  end

  def output_file_paths(template_file_paths) do
    template_file_paths
    |> Enum.map(&String.replace(&1, "templates/elixir", client_dir))
    |> Enum.map(&String.replace(&1, ".eex", ""))
    |> Enum.map(&String.replace(&1, "CLIENT_NAME", client_name))
  end

end
