defmodule Lye.EnvironmentTest do
  use ExUnit.Case
  alias Lye.Environment

  test "Loads asset correctly" do
    {asset, _environment} =
      Environment.phoenix("test")
      |> Environment.load("app.js")


    assert asset.name == "app.js"
    assert asset.load_path == "test/assets/js"
    assert asset.data == "// somelib/index.js\n\nvar somelib = \"I am somelib!\"\n// socket.js\n\nvar socket = \"I am socket.js\"\n// app.js\n\nvar app = \"I am app.js\"\n"

  end
end
