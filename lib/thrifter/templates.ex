defmodule Thrifter.Templates do
  require EEx

  alias Thrifter.Colors

  @templates_dir "templates"
  @thrifter_app_name :thrifter

  def template_files_for(lang) do
    lang |> templates_dir |> Thrifter.Directory.ls_r
  end

  def templates_dir(lang), do:
    [thrifter_repo_path, @templates_dir, lang |> Atom.to_string] |> Path.join

  defp thrifter_repo_path, do: Mix.Project.config[:deps][@thrifter_app_name] |> thrifter_dep

  defp thrifter_dep(nil),  do: "./"
  defp thrifter_dep(deps), do: deps |> thrifter_path

  defp thrifter_path([path: path]), do: path
  defp thrifter_path(_), do: Path.join(["deps", @thrifter_app_name |> Atom.to_string])

  def render(templates_paths, output_paths, template_variables) do
    Mix.shell.info "\nRendering templates:\n"

    Enum.zip(templates_paths, output_paths)
    |> Enum.each(fn {template, output} ->
      render_one_template(template, output, template_variables)
    end)
  end

  defp render_one_template(template, output, template_variables) do
    Mix.shell.info " - #{Colors.green(template)}"

    Path.dirname(output) |> File.mkdir_p!

    rendered = EEx.eval_file(template, template_variables)

    File.write!(output, rendered)
  end

end
