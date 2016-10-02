defmodule Mix.Tasks.Thrifter.Elixir do
  use Mix.Task
  alias Thrifter.Templates
  alias Thrifter.Thrift
  alias Thrifter.Colors

  @shortdoc "Generate Thrift Elixir client"

  def run(_) do
    Mix.shell.info "\n--- Generating elixir client ---\n"

    clean_output_dir
    generate_thrift_files
    generate_elixir_files

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
      service_name: service_name,
      function_names: function_names,
      structs: structs,
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

  def generate_thrift_files do
    Mix.shell.info "\nCompiling thrift client\n"

    output = "#{client_dir}/src"
    File.mkdir_p!(output)

    Thrift.generate(output: output, language: "erl")
  end

  defp function_names do
    "cd #{client_dir}/src; grep function_info *erl | grep \\(\\' | cut -d\\' -f2 | sort -u"
    |> os_cmd
    |> String.split
    |> Enum.map(&String.to_atom/1)
  end

  defp service_name do
    "cd #{client_dir}/src; grep function_info *erl | head -1 | cut -f1 -d."
    |> os_cmd
    |> String.strip(?\n)
  end

  defp structs do
    "cd #{client_dir}/src; grep \"struct_info('\" *_types.erl | awk -F \"'\" '{ print $2 }'"
    |> os_cmd
    |> String.split
  end

  defp os_cmd(cmd) do
    cmd |> to_char_list |> :os.cmd |> List.to_string
  end

end
