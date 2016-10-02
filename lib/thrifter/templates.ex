defmodule Thrifter.Templates do
  require EEx

  alias Thrifter.Colors

  @templates_dir "templates"

  def template_files_for(lang) do
    Thrifter.Directory.ls_r("#{@templates_dir}/#{lang}")
  end

  def render(templates_paths, output_paths, options) do
    Mix.shell.info "\nRendering templates:\n"

    Enum.zip(templates_paths, output_paths) |> Enum.each fn {template, output} ->
      Mix.shell.info " - #{Colors.green(output)}"

      Path.dirname(output) |> File.mkdir_p!

      File.write!(output, EEx.eval_file(template, options))
    end
  end

end
