defmodule Mix.Tasks.Thrifter.Ruby do
  use Mix.Task

  @gen_path "gen/ruby-client"
  @client_name "test_client"

  @lib_path "#{@gen_path}/lib"
  @bin_path "#{@gen_path}/bin"
  @templates_path "templates/ruby"

  def run(_args) do
    output_folder_structure
    Mix.shell.info "\n--> Generate folder structure"

    output_gemspec
    Mix.shell.info "--> Generate .gemspec"

    output_gemfile
    Mix.shell.info "--> Generate Gemfile"
  end

  defp output_folder_structure do
    File.rm_rf(@gen_path)
    File.mkdir_p(@gen_path)

    File.mkdir(@lib_path)
    File.mkdir(@bin_path)
  end

  defp output_gemspec do
    opts = [filename: @client_name, gem_name: @client_name, module_name: Macro.camelize(@client_name)]

    gemspec = EEx.eval_file("#{@templates_path}/template.gemspec.eex", opts)

    File.write(gempsec_path, gemspec)
  end

  defp output_gemfile do
    File.copy("#{@templates_path}/Gemfile", "#{@gen_path}/Gemfile")
  end

  defp gempsec_path do
    "#{@gen_path}/#{@client_name}.gemspec"
  end

end
