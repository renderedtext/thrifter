defmodule Thrifter.GitRepo do
  alias Thrifter.Colors

  @debug false

  def init(package_name, client_dir) do
    pushd(client_dir,
          "\nInitializing repozitory #{Colors.green(package_name)}",
          fn -> package_name |> create_remote |> init_local(package_name) end)
  end

  def create_package(output_paths, package_name, client_dir, version) do
    package = Colors.green("#{package_name}")
    f = fn ->
      git_cmd(~w(add) ++ files(output_paths, client_dir))
      git_cmd(~w(commit -m) ++ ['client version #{version}'])
      git_cmd(~w(tag v#{version}))
      git_cmd(~w(push origin master))
    end

    pushd(client_dir,
          "Creating package #{package}\n",
          f)

    Mix.shell.info("Package #{package} created in #{Colors.green(codecommit)}\n")
  end

  defp pushd(dir, message, f) do
    Mix.shell.info(message)

    {:ok, old_wd} = File.cwd
    File.cd!(dir)
    f.()
    File.cd!(old_wd)
  end

  defp create_remote(package_name) do
    run("aws", ~w(codecommit create-repository --repository-name #{package_name}))
  end

  defp files(output_paths, client_dir), do:
      output_paths |> Enum.map(&String.replace(&1, client_dir<>"/", ""))

  defp init_local(repo_create_response, package_name) do
    git_cmd(~w(init))
    git_cmd(~w(remote add origin #{codecommit}/#{package_name}))
    git_cmd(~w(config user.email 'devs@renderedtext.com'))
    git_cmd(~w(config user.name 'Rendered Text'))
    sync_repos(repo_create_response, package_name)
    git_cmd(~w(checkout master))
  end

  defp codecommit, do: "ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos"

  defp sync_repos(_repo_create_response = {_, 0}, package_name) do
    File.write("README.md", "#{package_name}")
    git_cmd(~w(add README.md))
    git_cmd(~w(commit -m) ++ ['Initial commit'])
    git_cmd(~w(push))
  end
  defp sync_repos(_repo_create_response, _client_name) do
    git_cmd(~w(pull origin master))
  end

  defp git_cmd(args) do run("git", args) end

  defp run(cmd, args) do
     run(cmd, args, @debug)
  end

  defp run(cmd, args, _debug = true) do
    IO.puts("Command: #{cmd}, #{inspect args}")
    {output, exit_code} = run_(cmd, args)
    IO.puts("Exit code: #{exit_code}, output: #{inspect output}")
    {output, exit_code}
  end
  defp run(cmd, args, _debug = false) do
    run_(cmd, args)
  end

  defp run_(cmd, args) do System.cmd(cmd, args, stderr_to_stdout: true) end
end
