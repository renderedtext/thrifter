defmodule Thrifter.TemplateManager do

  @generated_path "generated/"
  def generated_path, do: @generated_path

  def instantiate_templates(src_project_name, gen_project_name) do
    Mix.shell.cmd("echo; echo 'Instantiating templates...'")
    instantiate_template_mix_exs(gen_project_name)
    instantiate_template_supervisor(src_project_name, gen_project_name)
    instantiate_template_client(gen_project_name)
  end

  def instantiate_template_mix_exs(gen_project_name) do
    Mix.shell.cmd("echo; echo 'Instantiating template mix.exs ...'")
    template_name = "mix.exs"
    replacements = replacements_mix_exs(gen_project_name)

    instantiate(template_name, replacements, [gen_project_name, template_name])
  end

  def replacements_mix_exs(gen_project_name) do
    project_name_atom = gen_project_name |> String.to_atom |> inspect
    version = Mix.Project.config[:version]
    [project_name: Macro.camelize(gen_project_name), project_name_atom: project_name_atom,
      version: version]
  end

  def instantiate_template_supervisor(src_project_name, gen_project_name) do
    Mix.shell.cmd("echo; echo 'Instantiating template supervisor ...'")
    replacements = replacements_supervisor(src_project_name, gen_project_name)

    instantiate("supervisor.ex", replacements, [gen_project_name, "lib", gen_project_name <> ".ex"])
  end

  def replacements_supervisor(src_project_name, gen_project_name) do
    [project_name: Macro.camelize(gen_project_name),
      server_host: (src_project_name <> "_host") |> String.to_atom |> inspect,
      server_port: (src_project_name <> "_port") |> String.to_atom |> inspect]
  end

  def instantiate_template_client(gen_project_name) do
    Mix.shell.cmd("echo; echo 'Instantiating template client.ex ...'")
    template_name = "client.ex"
    replacements = replacements_client(gen_project_name)

    instantiate(template_name, replacements, [gen_project_name, "lib", template_name])
  end

  def replacements_client(gen_project_name) do
    [project_name: Macro.camelize(gen_project_name), function_names: inspect(function_names),
      service_name: inspect(service_name |> String.to_atom)]
  end

  def function_names do
    "cd src ; grep function_info *erl | grep \\(\\' | cut -d\\' -f2 | sort -u"
    |> os_cmd |> String.split |> Enum.map(fn f -> String.to_atom(f) end)
  end

  def service_name do
    "cd src ; grep function_info *erl | head -1 | cut -f1 -d."
    |> os_cmd |> String.strip(?\n)
  end

  def os_cmd(cmd), do: cmd |> to_char_list |> :os.cmd |> List.to_string

  def instantiate(template_name, replacements, target), do:
    template_name |> template_path |> EEx.eval_file(replacements) |> save_file(target)

  @thrifter_app_name :thrifter
  defp template_path(template_name) do
    project             = Mix.Project.config
    thrifter_dependancy = project[:deps][@thrifter_app_name] |> thrifter_dep
    [thrifter_dependancy, "templates", "elixir", template_name <> ".eex"] |> Path.join
  end

  def save_file(content, target), do:
    Path.join([generated_path] ++ target) |> File.write(content)

  defp thrifter_dep(nil),  do: "./"
  defp thrifter_dep(deps), do: deps |> thrifter_path

  defp thrifter_path([path: path]), do: path
  defp thrifter_path(_), do: Path.join(["deps", @thrifter_app_name |> Atom.to_string])

end
