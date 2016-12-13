defmodule Mix.Tasks.Thrifter.Elixir do
  use Mix.Task
  alias Thrifter.Templates
  alias Thrifter.Thrift
  alias Thrifter.Colors
  alias Thrifter.Directory
  alias Thrifter.GitRepo

  @shortdoc "Generate Thrift Elixir client"

  def client_dir, do: "gen/elixir-client"
  def thrift_output_dir, do: "#{client_dir}/src"
  def client_name, do: Mix.Project.config[:app] |> Atom.to_string
  def version, do: Mix.Project.config[:version]

  def run(_) do
    Mix.shell.info "Generating elixir client"
    Mix.shell.info "------------------------"

    Directory.clean(client_dir)
    GitRepo.init(package_name, client_dir)

    Thrift.generate(output: thrift_output_dir, language: "erl")
    output_paths = generate_elixir_files
    copyed_files = copy_files([{"mix.lock", "./mix.lock"}])

    Mix.shell.info "\nElixir client generated in #{Colors.green(client_dir)}\n"

    output_paths ++ copyed_files
    |> GitRepo.create_package(package_name, client_dir, version)
  end

  defp copy_files(files) do
    Mix.shell.info "\nCopying files"

    files
    |> Enum.each(fn {src, dest} ->
      System.cmd("cp", [src, "#{client_dir}/#{dest}"])
      Mix.shell.info " - #{Colors.green(src)}"
    end)

    Enum.map(files, fn {_src, dest} -> dest end)
  end

  defp generate_elixir_files do
    template_paths = Templates.template_files_for(:elixir)
    output_paths   = output_file_paths(template_paths)

    Templates.render(template_paths, output_paths, template_variables)

    output_paths
  end

  defp template_variables do
    structs_as_atoms =
      Thrift.Erlang.structs(thrift_output_dir)
      |> Enum.map(fn s -> s |> String.to_atom end)

    [
      client_name: client_name,
      client_name_atom: client_name |> eex_atom,
      client_module_name: Macro.camelize(client_name),
      service_name: Thrift.Erlang.service_name(thrift_output_dir) |> eex_atom,
      function_names: Thrift.Erlang.function_names(thrift_output_dir),
      structs_as_atoms: structs_as_atoms,
      erl_fajl_name: Thrift.Erlang.erl_fajl_name(thrift_output_dir),
      version: version
    ]
  end

  defp eex_atom(string), do: string |> String.to_atom |> inspect

  def output_file_paths(template_file_paths) do
    template_file_paths
    |> Enum.map(&String.replace(&1, Templates.templates_dir(:elixir), client_dir))
    |> Enum.map(&String.replace(&1, ".eex", ""))
    |> Enum.map(&String.replace(&1, "CLIENT_NAME", client_name))
  end

  defp package_name do
    (client_name |> String.replace("_", "-")) <> "-generated-client"
  end
end
