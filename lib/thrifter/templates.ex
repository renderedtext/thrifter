defmodule Thrifter.Templates do
  require EEx

  @templates_dir "templates"

  def template_files_for(lang) do
    Thrifter.Directory.ls_r("#{@templates_dir}/#{lang}")
  end

  def render(templates_path, options) do
    EEx.eval_file(templates_path, options)
  end

  def render_all(template_file_paths, options) do
    template_file_paths |> Enum.map(&render(&1, options))
  end

end
