defmodule Mix.Tasks.Thrifter.Ruby do
  use Mix.Task
  alias Thrifter.Templates
  alias Thrifter.Thrift
  alias Thrifter.Colors
  alias Thrifter.Directory

  @shortdoc "Generate Thrift Ruby client"

  def client_dir,  do: "gen/ruby-client"
  def client_name, do: Mix.Project.config[:app] |> Atom.to_string

  def run(_) do
    Mix.shell.info "Generating ruby client"
    Mix.shell.info "----------------------"

    Directory.clean(client_dir)
    Thrift.generate(output: "#{client_dir}/lib/#{client_name}", language: "rb")
    generate_ruby_files

    Mix.shell.info "\nRuby client generated in #{Colors.green(client_dir)}\n"
  end

  defp generate_ruby_files do
    template_variables = [
      gem_name: client_name,
      module_name: Macro.camelize(client_name),
      version: Mix.Project.config[:version]
    ]

    template_paths = Templates.template_files_for(:ruby)
    output_paths   = output_file_paths(template_paths)

    Templates.render(template_paths, output_paths, template_variables)
  end

  def output_file_paths(template_file_paths) do
    template_file_paths
    |> Enum.map(&String.replace(&1, ".eex", ""))
    |> Enum.map(&String.replace(&1, "templates/ruby", client_dir))
    |> Enum.map(&String.replace(&1, "GEM_NAME", client_name))
  end

end
