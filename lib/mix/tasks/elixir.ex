defmodule Mix.Tasks.Thrifter.Elixir do
  use Mix.Task

  @shortdoc "Generate Thrift Elixir client"

  def run(_) do
    Mix.shell.info "\n--- Generating elixir client ---\n"

    clean_output_dir
    generate_elixir_files
    generate_thrift_files

    Mix.shell.info "\Elixir client generated in #{Colors.green(client_dir)}\n"
  end

  defp client_dir do
    "gen/elixir-client"
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
      service_name:
      version: Mix.Project.config[:version]
    ]

    template_file_paths = Templates.template_files_for(:ruby)
    output_file_paths   = template_file_paths
                          |> Enum.map(&String.replace(&1, "CLIENT_NAME", client_name))
                          |> Enum.map(&String.replace(&1, "templates/elixir", client_dir))

    Mix.shell.info "\nRendering elixir files:\n"

    Enum.zip(template_file_paths, output_file_paths) |> Enum.each fn {template, output} ->
      Mix.shell.info " - #{Colors.green(output)}"

      Path.dirname(output) |> File.mkdir_p!

      File.write! output, Templates.render(template, options)
    end
  end

  def generate_thrift_files do
    Mix.shell.info "\nCompiling thrift client\n"
    Thrift.generate(output: "#{client_dir}/lib/#{client_name}", language: "rb")
  end

end
