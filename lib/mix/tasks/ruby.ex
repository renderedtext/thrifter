defmodule Mix.Tasks.Thrifter.Ruby do
  use Mix.Task

  @gen_path "gen/ruby-client"
  @client_name "test_client"

  @lib_path "#{@gen_path}/lib"
  @bin_path "#{@gen_path}/bin"
  @templates_path "templates/ruby"

  @version "0.1.0"
  @thrift_dir "thrift"

  def run(_args) do
    Mix.shell.info "\nGenerating ruby client\n"

    File.mkdir_p!("temp/template")

    process_dir(@templates_path)
    # generate_thrift_files

    # File.rm_rf!("temp/template")

    Mix.shell.info "\nDone!\n"
  end

  defp process_dir(path) do
    {:ok, files} = File.ls(path)

    Enum.each files, fn file ->
      file_path = "#{path}/#{file}"

      if File.dir?(file_path) do
        File.mkdir("temp/template/#{file}")
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

    File.write!("temp/template/#{dirname}/#{basename(path)}", eval)

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
    Mix.shell.info "--> Compiling \e[32mthrift\e[0m files"

    {:ok, thrift_files} = File.ls(@thrift_dir)

    File.rm_rf("temp/thrift")
    File.mkdir_p("temp/thrift")

    for file <- thrift_files do
      System.cmd("thrift", ["-r", "--gen", "rb", "-out", "temp/thrift", "#{@thrift_dir}/#{file}"])

      Mix.shell.info "\t- Compiling \e[33m#{file}\e[0m"
    end

    {:ok, ruby_files} = File.ls("temp/thrift")

    for file <- ruby_files do
      {:ok, data} = File.read("temp/thrift/#{file}")
      File.write("#{@lib_path}/#{@client_name}/#{file}", data)
    end

    File.rm_rf("temp")
  end

end
