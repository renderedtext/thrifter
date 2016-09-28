defmodule Mix.Tasks.Thrifter.Elixir do
  use Mix.Task

  @shortdoc "Generate Thrift Elixir client"


  def run(_) do
    {src_prj_name, gen_prj_name} = generate_project()
    compile_thrift(gen_prj_name)
    Thrifter.TemplateManager.instantiate_templates(src_prj_name, gen_prj_name)
    compile_elixir(gen_prj_name)
  end

  @prj_suffix "_generated_client"
  def generate_project() do
    print_and_exec("rm -fr #{generated_path}")
    print_and_exec("mkdir  #{generated_path}")

    project        = Mix.Project.config
    src_prj_name   = Keyword.get(project, :app) |> Atom.to_string
    gen_prj_name   = src_prj_name <> @prj_suffix

    print_and_exec("cd #{generated_path}; mix new #{gen_prj_name} --sup")

    {src_prj_name, gen_prj_name}
  end

  def compile_thrift(gen_prj_name) do
    print_and_exec("rm -fr src")
    print_and_exec("mix compile.thrift")
    print_and_exec("cp -r src #{generated_path}/#{gen_prj_name}/")
  end

  def compile_elixir(gen_prj_name) do
    gen_prj_path = "#{generated_path}/#{gen_prj_name}"
    print_and_exec("cd #{gen_prj_path}; MIX_ENV=prod mix do deps.get, compile")
  end

  def print_and_exec(cmd) do
    Mix.shell.cmd("echo; echo '$ #{cmd}'")
    Mix.shell.cmd(cmd)
  end

  def generated_path, do: Thrifter.TemplateManager.generated_path
end
