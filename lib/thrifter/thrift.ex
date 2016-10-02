defmodule Thrift do
  alias Thrift.Directory

  @thrift_dir "thrift"

  def files do
    Directory.ls(@thrift_dir)
  end

  def generate([output: output, language: lang]) do
    files |> Enum.each fn file ->
      Mix.shell.info " - #{IO.ANSI.green}#{file}#{IO.ANSI.reset}"

      System.cmd("thrift", ["-r", "--gen", lang, "-out", output, file])
    end
  end

end
