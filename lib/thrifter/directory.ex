defmodule Thrifter.Directory do

  # List files in a directory
  def ls(path) do
    File.ls!(path) |> Enum.map(&Path.join(path, &1))
  end

  # List files recursevly in a directory
  def ls_r(path) do
    if File.dir?(path) do
      ls(path) |> Enum.map(&ls_r/1) |> Enum.concat
    else
      [path]
    end
  end

end
