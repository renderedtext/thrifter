defmodule Thrifter.Templates do
  require EEx

  alias Thrifter.Colors

  @templates_dir "templates"

  def template_files_for(lang) do
    Thrifter.Directory.ls_r("#{@templates_dir}/#{lang}")
  end

  def render(templates_paths, output_paths, template_variables) do
    Mix.shell.info "\nRendering templates:\n"

    Enum.zip(templates_paths, output_paths)
    |> Enum.each fn {template, output} ->
      render_one_template(template, output, template_variables)
    end
  end

  defp render_one_template(template, output, template_variables) do
    Mix.shell.info " - #{Colors.green(output)}"

    Path.dirname(output) |> File.mkdir_p!

    rendered = EEx.eval_file(template, template_variables)

    File.write!(output, rendered)
  end

end
