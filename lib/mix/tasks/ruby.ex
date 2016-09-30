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
    Mix.shell.info "\n-- Generating ruby client\n"

    generate_folder_structure
    generate_gemspec
    generate_gemfile
    generate_lib
    generate_bin
    generate_thrift_files

    Mix.shell.info "-- \e[32mDone!\n"
  end

  defp generate_folder_structure do
    File.rm_rf(@gen_path)
    File.mkdir_p(@gen_path)

    File.mkdir(@lib_path)
    File.mkdir("#{@lib_path}/#{@client_name}")
    File.mkdir(@bin_path)
  end

  defp generate_gemspec do
    Mix.shell.info "--> Generating \e[32m.gemspec\e[0m"

    opts = [filename: @client_name, gem_name: @client_name, module_name: Macro.camelize(@client_name)]

    gemspec = EEx.eval_file("#{@templates_path}/template.gemspec.eex", opts)

    File.write(gempsec_path, gemspec)
  end

  defp generate_gemfile do
    Mix.shell.info "--> Generating \e[32mGemfile\e[0m"

    File.copy("#{@templates_path}/Gemfile", "#{@gen_path}/Gemfile")
  end

  defp generate_lib do
    Mix.shell.info "--> Generating \e[32mlib\e[0m folder"

    opts = [module_name: Macro.camelize(@client_name), version: @version]
    version = EEx.eval_file("#{@templates_path}/lib/version.rb.eex", opts)

    File.write("#{@lib_path}/#{@client_name}/version.rb", version)

    opts = [module_name: Macro.camelize(@client_name)]
    gem_module = EEx.eval_file("#{@templates_path}/lib/gem_name.rb.eex", opts)

    File.write("#{@lib_path}/#{@client_name}.rb", gem_module)
  end

  defp generate_bin do
    Mix.shell.info "--> Generating \e[32mbin\e[0m folder"

    File.copy("#{@templates_path}/bin/setup", "#{@bin_path}/setup")
    File.chmod("#{@bin_path}/setup", 755)

    opts = [gem_name: @client_name]

    console = EEx.eval_file("#{@templates_path}/bin/console.eex", opts)

    File.write("#{@bin_path}/console", console)
    File.chmod("#{@bin_path}/console", 755)
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

  defp gempsec_path do
    "#{@gen_path}/#{@client_name}.gemspec"
  end

end
