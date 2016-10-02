defmodule Thrifter.Thrift do
  alias Thrifter.Directory

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

  defmodule RiffedHelpers do
    defp function_names(erlang_source_directory) do
      "cd #{erlang_source_directory} ; grep function_info *erl | grep \\(\\' | cut -d\\' -f2 | sort -u"
      |> os_cmd |> String.split |> Enum.map(fn f -> String.to_atom(f) end)
    end

    defp service_name(erlang_source_directory) do
      "cd #{erlang_source_directory} ; grep function_info *erl | head -1 | cut -f1 -d."
      |> os_cmd |> String.strip(?\n)
    end
  end

end
