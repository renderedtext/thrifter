defmodule Thrifter.Thrift do
  alias Thrifter.Directory

  @thrift_dir "thrift"

  def files do
    Directory.ls(@thrift_dir)
  end

  def generate([output: output, language: lang]) do
    Mix.shell.info "\nCompiling thrift client\n"

    File.mkdir_p!(output)

    files |> Enum.each(fn file ->
      Mix.shell.info " - #{IO.ANSI.green}#{file}#{IO.ANSI.reset}"

      System.cmd("thrift", ["-r", "--gen", lang, "-out", output, file])
    end)
  end

  defmodule Erlang do
    def function_names(erlang_source_path) do
      "cd #{erlang_source_path}; grep function_info *erl | grep \\(\\' | cut -d\\' -f2 | sort -u"
      |> os_cmd
      |> String.split
      |> Enum.map(&String.to_atom/1)
    end

    def service_name(erlang_source_path) do
      "cd #{erlang_source_path}; grep function_info *erl | head -1 | cut -f1 -d."
      |> os_cmd
      |> String.strip(?\n)
    end

    def structs(erlang_source_path) do
      "cd #{erlang_source_path}; grep \"struct_info('\" *_types.erl | awk -F \"'\" '{ print $2 }'"
      |> os_cmd
      |> String.split
    end

    # TODO Works only for **ONE** .thrift file in directory
    def erl_fajl_name(erlang_source_path) do
      File.ls!(erlang_source_path)
      |> Enum.find(fn file -> file |> String.ends_with?("types.erl") end)
      |> String.split(".") |> Enum.at(0)
    end

    defp os_cmd(cmd) do
      cmd |> to_char_list |> :os.cmd |> List.to_string
    end
  end

end
