defmodule Thrifter.Templates do
  require EEx

  def template_files_for(lang) do
    template_files("templates/#{Atom.to_string(lang)}")
  end

  def render(templates_path, options) do
    EEx.eval_file(templates_path, options)
  end

  defp template_files(dir, acc \\ []) do
    Enum.reduce(File.ls!(dir), acc, fn(file, acc) ->
      file_path = "#{dir}/#{file}"

      if File.dir?(file_path) do
        template_files(file_path, acc)
      else
        [file_path | acc]
      end
    end)
  end
end
