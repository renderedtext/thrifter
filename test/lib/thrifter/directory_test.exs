defmodule Thrifter.DirectoryTest do
  use ExSpec

  alias Thrifter.Directory

  describe ".ls" do
    it "lists files in a directory" do
      assert Directory.ls("test") |> Enum.member?("test/test_helper.exs")
    end

    context "when the directory does not exist" do
      it "raises an exception" do
        assert_raise File.Error, fn -> Directory.ls("random_nonexisting_dir") end
      end
    end
  end

  describe ".ls_r" do
    it "lists files in a directory" do
      files = Directory.ls_r("test")

      assert files |> Enum.member?("test/test_helper.exs")
    end

    it "lists files in subdirectories" do
      files = Directory.ls_r("test")

      assert files |> Enum.member?("test/lib/thrifter/directory_test.exs")
    end
  end
end
