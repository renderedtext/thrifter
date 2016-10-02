defmodule Mix.Tasks.Thrifter.Ruby do
  use Mix.Task
  alias Thrifter.Templates
  alias Thrifter.Thrift

  def run(_args) do
    Mix.shell.info "\n--- Generating ruby client ---\n"

    clean_output_dir
    generate_ruby_files
    generate_thrift_files

    Mix.shell.info "\nRuby client generated in #{green(client_dir)}\n"
  end

  defp client_dir do
    "gen/ruby-client"
  end

  defp client_name do
    Mix.Project.config[:app] |> Atom.to_string
  end

  defp clean_output_dir do
    File.rm_rf!(client_dir)
    File.mkdir_p!(client_dir)
  end

  defp generate_ruby_files do
    options = [
      filename: client_name,
      gem_name: client_name,
      module_name: Macro.camelize(client_name),
      version: Mix.Project.config[:version]
    ]

    template_file_paths = Templates.template_files_for(:ruby)
    output_file_paths   = template_file_paths
                          |> Enum.map(&String.replace(&1, "GEM_NAME", client_name))
                          |> Enum.map(&String.replace(&1, "templates/ruby", client_dir))

    Mix.shell.info "\nRendering ruby files:\n"

    Enum.zip(template_file_paths, output_file_paths) |> Enum.each fn {template, output} ->
      Mix.shell.info " - #{green(output)}"

      Path.dirname(output) |> File.mkdir_p!

      File.write! output, Templates.render(template, options)
    end
  end

  def generate_thrift_files do
    Mix.shell.info "\nCompiling thrift client\n"
    Thrift.generate(output: "#{client_dir}/lib/#{client_name}", language: "rb")
  end

  defp green(text) do
    "#{IO.ANSI.green}#{text}#{IO.ANSI.reset}"
  end

end
