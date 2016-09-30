defmodule Mix.Tasks.Thrifter.Ruby do
  use Mix.Task

  @client_name Mix.Project.config[:app] |> Atom.to_string
  @gen_path "gen/ruby-client"
  @templates_path "templates/ruby"

  @version Mix.Project.config[:version]
  @thrift_dir "thrift"

  def run(_args) do
    Mix.shell.info "\nGenerating ruby client\n"

    File.rm_rf!("#{@gen_path}")
    File.mkdir_p!("#{@gen_path}")

    Thrifter.Templates.template_files_for(:ruby)
    |> render_templates

    generate_thrift_files

    Mix.shell.info "\nDone!\n"
  end

  defp render_templates(templates) do
    options = [
      filename: @client_name,
      gem_name: @client_name,
      module_name: Macro.camelize(@client_name),
      version: @version
    ]

    Enum.each templates, fn template ->
      rendered = Thrifter.Templates.render(template, options)

      replace_path(template) |> File.write!(rendered)

      Mix.shell.info "-- Rendered #{IO.ANSI.green()} #{replace_path(template)} #{IO.ANSI.reset}"
    end
  end

  defp generate_thrift_files do
    Mix.shell.info "\n-- Compiling #{IO.ANSI.red()} thrift #{IO.ANSI.reset()} files"

    {:ok, thrift_files} = File.ls(@thrift_dir)

    Enum.each thrift_files, fn file ->
      System.cmd("thrift", ["-r", "--gen", "rb", "-out", "#{@gen_path}/lib/#{@client_name}", "#{@thrift_dir}/#{file}"])

      Mix.shell.info "\t- Compiled #{IO.ANSI.green()} #{file} #{IO.ANSI.reset}"
    end

    Mix.shell.info "-- Compiling done\n"
  end

  defp replace_path(file) do
    base = replace_file_name(file)
    dir  = Path.dirname(file) |> replace_dir_name

    File.mkdir_p(dir)

    "#{dir}/#{base}"
  end

  defp replace_file_name(path) do
    base = Path.basename(path, ".eex")

    case base do
      ".gemspec"    -> "#{@client_name}.gemspec"
      "gem_name.rb" -> "#{@client_name}.rb"
      _             -> base
    end
  end

  defp replace_dir_name(path) do
    out_path = String.replace(path, @templates_path, @gen_path)

    case Path.basename(out_path) do
      "gem_name" -> String.replace(out_path, "gem_name", @client_name)
      _          -> out_path
    end
  end

end
