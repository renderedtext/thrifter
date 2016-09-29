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
    generate_folder_structure
    generate_gemspec
    generate_gemfile
    generate_lib
    generate_bin
    generate_thrift_files
  end

  defp generate_folder_structure do
    File.rm_rf(@gen_path)
    File.mkdir_p(@gen_path)

    File.mkdir(@lib_path)
    File.mkdir("#{@lib_path}/#{@client_name}")
    File.mkdir(@bin_path)

    Mix.shell.info "--> Generating folder structure"
  end

  defp generate_gemspec do
    opts = [filename: @client_name, gem_name: @client_name, module_name: Macro.camelize(@client_name)]

    gemspec = EEx.eval_file("#{@templates_path}/template.gemspec.eex", opts)

    File.write(gempsec_path, gemspec)

    Mix.shell.info "--> Generating .gemspec"
  end

  defp generate_gemfile do
    File.copy("#{@templates_path}/Gemfile", "#{@gen_path}/Gemfile")

    Mix.shell.info "--> Generating Gemfile"
  end

  defp generate_lib do
    opts = [module_name: Macro.camelize(@client_name), version: @version]
    version = EEx.eval_file("#{@templates_path}/lib/version.rb.eex", opts)

    File.write("#{@lib_path}/#{@client_name}/version.rb", version)

    opts = [module_name: Macro.camelize(@client_name)]
    gem_module = EEx.eval_file("#{@templates_path}/lib/gem_name.rb.eex", opts)

    File.write("#{@lib_path}/#{@client_name}.rb", gem_module)
  end

  defp generate_bin do
    File.copy("#{@templates_path}/bin/setup", "#{@bin_path}/setup")
    File.chmod("#{@bin_path}/setup", 755)

    opts = [gem_name: @client_name]

    console = EEx.eval_file("#{@templates_path}/bin/console.eex", opts)

    File.write("#{@bin_path}/console", console)
    File.chmod("#{@bin_path}/console", 755)

    Mix.shell.info "--> Generating bin folder"
  end

  defp generate_thrift_files do
    {:ok, thrift_files} = File.ls(@thrift_dir)

    File.rm_rf("temp/thrift")
    File.mkdir_p("temp/thrift")

    Mix.shell.info "--> Compiling thrift files"

    for file <- thrift_files do
      System.cmd("thrift", ["-r", "--gen", "rb", "-out", "temp/thrift", "#{@thrift_dir}/#{file}"])
      Mix.shell.info "\t-- Compiling #{file}"
    end

    {:ok, ruby_files} = File.ls("temp/thrift")

    for file <- ruby_files do
      {:ok, data} = File.read("temp/thrift/#{file}")
      File.write("#{@lib_path}/#{@client_name}/#{file}", data)

      # Mix.shell.info "\t-- Copy #{file}"
    end

    File.rm_rf("temp")

    Mix.shell.info "--> Compiled thrift files"
  end

  defp gempsec_path do
    "#{@gen_path}/#{@client_name}.gemspec"
  end

end
