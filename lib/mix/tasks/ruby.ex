defmodule Mix.Tasks.Thrifter.Ruby do
  use Mix.Task

  @gen_path "gen/ruby-client"
  @client_name "test_client"

  @lib_path "#{@gen_path}/lib"
  @bin_path "#{@gen_path}/bin"
  @templates_path "templates/ruby"

  def run(_args) do
    generate_folder_structure
    generate_gemspec
    generate_gemfile
    generate_lib
    generate_bin
  end

  defp generate_folder_structure do
    File.rm_rf(@gen_path)
    File.mkdir_p(@gen_path)

    File.mkdir(@lib_path)
    File.mkdir(@bin_path)

    Mix.shell.info "--> Generate folder structure"
  end

  defp generate_gemspec do
    opts = [filename: @client_name, gem_name: @client_name, module_name: Macro.camelize(@client_name)]

    gemspec = EEx.eval_file("#{@templates_path}/template.gemspec.eex", opts)

    File.write(gempsec_path, gemspec)

    Mix.shell.info "--> Generate .gemspec"
  end

  defp generate_gemfile do
    File.copy("#{@templates_path}/Gemfile", "#{@gen_path}/Gemfile")

    Mix.shell.info "--> Generate Gemfile"
  end

  defp generate_lib do

  end

  defp generate_bin do
    File.copy("#{@templates_path}/bin/setup", "#{@bin_path}/setup")
    File.chmod("#{@bin_path}/setup", 755)

    opts = [gem_name: @client_name]

    console = EEx.eval_file("#{@templates_path}/bin/console.eex", opts)

    File.write("#{@bin_path}/console", console)
    File.chmod("#{@bin_path}/console", 755)

    Mix.shell.info "--> Generate bin folder"
  end

  defp gempsec_path do
    "#{@gen_path}/#{@client_name}.gemspec"
  end

end
