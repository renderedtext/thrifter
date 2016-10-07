defmodule Thrifter.GitRepo do
  alias Thrifter.Colors

  @debug false
  @generated_repo_private? false

  defp repo_user, do: System.get_env("REPO_USER")
  defp repo_pass, do: System.get_env("REPO_PASS")

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

    Mix.shell.info("Package created in #{Colors.green(repo_url)}/#{package}\n")
  end

  defp pushd(dir, message, f) do
    Mix.shell.info(message)

    {:ok, old_wd} = File.cwd
    File.cd!(dir)
    f.()
    File.cd!(old_wd)
  end

  defp create_remote(package_name) do
    args = ~w(-s --user #{repo_user}:#{repo_pass}
      -X POST -H "Content-Type: application/json" -d) ++
      ['{"scm": "git", "is_private": "#{@generated_repo_private?}"}',
      "https://api.bitbucket.org/2.0/repositories/#{repo_user}/#{package_name}"]

    run("curl", args) |> validate_create_remote
  end

  defp validate_create_remote({output, 0}), do:
     if(String.contains?(output, err_str), do: {:error, output}, else: {:ok, output})

  def err_str, do: inspect(~s(error)) <> ":"

  defp files(output_paths, client_dir), do:
      output_paths |> Enum.map(&String.replace(&1, client_dir<>"/", ""))

  defp init_local(create_remote_response, package_name) do
    git_cmd(~w(init))
    git_cmd(~w(remote add origin #{repo_url_pass}/#{package_name}))
    git_cmd(~w(config user.email 'devs@renderedtext.com'))
    git_cmd(~w(config user.name 'Rendered Text'))
    sync_repos(create_remote_response, package_name)
    git_cmd(~w(checkout master))
  end

  defp repo_url_pass, do: repo_url_base(":#{repo_pass}")
  defp repo_url, do: repo_url_base("")
  defp repo_url_base(pass), do: "https://#{repo_user}#{pass}@bitbucket.org/#{repo_user}"

  defp sync_repos(_create_remote_response = {:ok, _}, package_name) do
    File.write("README.md", "#{package_name}")
    git_cmd(~w(add README.md))
    git_cmd(~w(commit -m) ++ ['Initial commit'])
    git_cmd(~w(push))
  end
  defp sync_repos(_create_remote_response, _client_name) do
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
