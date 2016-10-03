defmodule Thrifter.TemplatesTest do
  use ExSpec

  alias Thrifter.Templates

  describe ".template_files_for" do
    it "lists template files for the given language" do
      files = Templates.template_files_for(:ruby)

      assert files |> Enum.member?("./templates/ruby/Gemfile.eex")
    end

    context "when the passed language is not supported" do
      it "raises an exception" do
        assert_raise RuntimeError, fn ->
          Templates.template_files_for(:go)
        end
      end
    end
  end

end
