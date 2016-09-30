defmodule Mix.Tasks.Thrifter.Ruby do
  use Mix.Task

  @gen_path "gen/ruby-client"
  @client_name "test_client"
  @templates_path "templates/ruby"

  @version Mix.Project.config[:version]
  @thrift_dir "thrift"

  def run(_args) do
    Mix.shell.info "\nGenerating ruby client\n"

    File.mkdir_p!("#{@gen_path}")

    process_dir(@templates_path)
    generate_thrift_files

    Mix.shell.info "\nDone!\n"
  end

  defp process_dir(path) do
    {:ok, files} = File.ls(path)

    Enum.each files, fn file ->
      file_path = "#{path}/#{file}"

      if File.dir?(file_path) do
        File.mkdir("#{@gen_path}/#{file}")
        process_dir(file_path)
      else
        process_file(file_path)
      end
    end
  end

  defp process_file(path) do
    dirname =
      Path.relative_to(path, @templates_path)
      |> Path.dirname

    opts = [
      filename: @client_name,
      gem_name: @client_name,
      module_name: Macro.camelize(@client_name),
      version: @version
    ]

    eval = EEx.eval_file(path, opts)

    File.write!("#{@gen_path}/#{dirname}/#{basename(path)}", eval)

    Mix.shell.info "-- Generated #{IO.ANSI.green()} #{dirname}/#{basename(path)} #{IO.ANSI.reset}"
  end

  defp basename(path) do
    base = Path.basename(path, ".eex")

    case Path.extname(base) do
      ".gemspec" -> "#{@client_name}.gemspec"
      _ -> base
    end
  end

  defp generate_thrift_files do
    Mix.shell.info "\n-- Compiling #{IO.ANSI.red()} thrift #{IO.ANSI.reset()} files"

    {:ok, thrift_files} = File.ls(@thrift_dir)

    File.mkdir_p!("#{@gen_path}/lib/#{@client_name}")

    Enum.each thrift_files, fn file ->
      System.cmd("thrift", ["-r", "--gen", "rb", "-out", "#{@gen_path}/lib/#{@client_name}", "#{@thrift_dir}/#{file}"])

      Mix.shell.info "\t- Compiled #{IO.ANSI.green()} #{file} #{IO.ANSI.reset}"
    end

    Mix.shell.info "-- Compiling done\n"
  end

end
