defmodule Thrifter.Directory do

  # List files in a directory
  def ls(path) do
    File.ls!(path) |> Enum.map(&Path.join(path, &1))
  end

  # List files recursevly in a directory
  def ls_r(path) do
    cond do
      File.dir?(path) ->
        ls(path) |> Enum.map(&ls_r/1) |> Enum.concat
      File.regular?(path) ->
        [path]
      true ->
        raise "Path does not exists"
    end
  end

  # clean content of directory
  def clean(path) do
    File.rm_rf!(path)
    File.mkdir_p!(path)
  end

end
