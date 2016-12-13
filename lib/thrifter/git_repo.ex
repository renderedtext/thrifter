defmodule Thrifter.GitRepo do
  alias Thrifter.Colors

  defp repo_user, do: System.get_env("REPO_USER")
  defp repo_pass, do: System.get_env("REPO_PASS")
  defp org_id, do: System.get_env("ORG_ID")

  defp repo_public?, do: System.get_env("REPO_PUBLIC") == "true"
  defp debug?, do: System.get_env("DEBUG") == "true"

  def init(package_name, client_dir) do
    pushd(client_dir,
      "\nInitializing repository #{Colors.green(package_name)}",
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

  def create_remote(name) do
    name
    |> remote_exists?
    |> if(do: :existing, else: :new)
    |> create_remote_(name)
  end

  def create_remote_(:new, remote_name) do
    args = ~w(-u #{repo_user}:#{repo_pass} -X POST -d) ++
      ['{"name": "#{remote_name}", "private": #{!repo_public?}}',
      "https://api.github.com/orgs/#{org_id}/repos"]

    curl(args) |> decode |> validate_create_remote(remote_name)
  end
  def create_remote_(:existing, _remote_name), do: {:ok, "Remote already exists"}

  def remote_exists?(remote_name), do: !!get_remote(remote_name)["name"]

  def get_remote(remote_name) do
    args = ~w(-u #{repo_user}:#{repo_pass} -X GET) ++
      ["https://api.github.com/repos/#{org_id}/#{remote_name}"]

    curl(args) |> decode
  end

  def delete_remote(remote_name) do
    args = ~w(-u #{repo_user}:#{repo_pass} -X DELETE) ++
      ["https://api.github.com/repos/#{org_id}/#{remote_name}"]

    curl(args)
  end

  defp validate_create_remote(response, name) do
    status = if(response["name"] == name, do: :ok, else: :error)

    {status, response}
  end

  defp curl(args), do: run("curl", args) 

  defp decode(message), do: message |> elem(0) |> Poison.decode!

  def err_str, do: inspect(~s(error)) <> ":"

  defp files(output_paths, client_dir), do:
      output_paths |> Enum.map(&String.replace(&1, client_dir<>"/", ""))

  defp init_local(create_remote_response, package_name) do
    git_cmd(~w(init))
    git_cmd(~w(remote add origin #{repo_url_pass}/#{package_name}))
    git_cmd(~w(config user.email 'devs@renderedtext.com'))
    git_cmd(~w(config user.name 'RenderedText'))
    sync_repos(create_remote_response, package_name)
    git_cmd(~w(checkout master))
  end

  defp repo_url_pass, do: repo_url_base(":#{repo_pass}")
  defp repo_url, do: repo_url_base("")
  defp repo_url_base(pass), do: "https://#{repo_user}#{pass}@github.com/#{org_id}"

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
     run(cmd, args, debug?)
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

  defp run_(cmd, args) do System.cmd(cmd, args) end
end
