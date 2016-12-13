defmodule Thrifter.GitRepoTest do
  use ExUnit.Case

  alias Thrifter.GitRepo

  setup_all do
    id = UUID.uuid1

    File.mkdir(id)
    GitRepo.init(id, id)

    on_exit fn ->
      File.rm_rf(id)
      GitRepo.delete_remote(id)
    end

    {:ok, [id: id]}
  end

  test "repo creation", context do
    assert context[:id] |> GitRepo.remote_exists?
  end

  test "duplicate repo creation", context do
    response = context[:id] |> GitRepo.create_remote

    assert response == {:ok, "Remote already exists"}
  end
end
