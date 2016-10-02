defmodule Thrifter.Colors do

  def green(text) do
    "#{IO.ANSI.green}#{text}#{IO.ANSI.reset}"
  end

  def red(text) do
    "#{IO.ANSI.red}#{text}#{IO.ANSI.reset}"
  end

end
