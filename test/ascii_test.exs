defmodule AsciiTest do
  use ExUnit.Case
  doctest Ascii

  test "greets the world" do
    assert Ascii.hello() == :world
  end
end
