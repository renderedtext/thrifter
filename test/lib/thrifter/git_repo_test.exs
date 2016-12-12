defmodule Thrifter.GitRepoTest do
  use ExUnit.Case

  alias Thrifter.GitRepo

  setup do
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
    assert context[:id] |> found?
  end

  defp found?(id) do
    id 
    |> GitRepo.get_remote 
    |> elem(0) 
    |> String.contains?("Not Found")
    |> Kernel.not
  end
end
