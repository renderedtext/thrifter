defmodule Thrifter.Templates do
  require EEx
  alias Thrifter.Directory

  @templates_dir "templates"

  def template_files_for(:ruby),   do: Directory.ls_r("#{@templates_dir}/ruby")
  def template_files_for(:elixir), do: Directory.ls_r("#{@templates_dir}/elixir")

  def render(templates_path, options) do
    EEx.eval_file(templates_path, options)
  end

end
