defmodule Lye.Processing.DirectiveProcessorTest do
  use ExUnit.Case
  alias Lye.Processing.DirectiveProcessor

  test "finds directives in content" do
    fixture = ~s"""
    // this is a test
    //= require otherfile
    //= require_tree .

    some data
    /*
     * This is a multiline comment
     *= require something else
     */

    more data
    # Comment
      #= link that/file
    """
    {directives, _data} = DirectiveProcessor.find_directives(fixture)
    assert directives == ["//= require otherfile","//= require_tree ."," *= require something else","  #= link that/file"]
  end

  test "parses directives correctly" do

    fixture1 = "//= require otherfile"
    fixture2 = "//= require_tree ."
    fixture3 = " *= require something else"
    fixture4 = "  #= link that/file"

    assert DirectiveProcessor.parse_directive_line(fixture1) == %{"directive" => "require", "args" => "otherfile"}
    assert DirectiveProcessor.parse_directive_line(fixture2) == %{"directive" => "require_tree", "args" => "."}
    assert DirectiveProcessor.parse_directive_line(fixture3) == %{"directive" => "require", "args" => "something else"}
    assert DirectiveProcessor.parse_directive_line(fixture4) == %{"directive" => "link", "args" => "that/file"}
  end

end
