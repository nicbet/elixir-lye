defmodule LyeTest do
  use ExUnit.Case
  doctest Lye

  test "greets the world" do
    assert Lye.hello() == :world
  end
end
