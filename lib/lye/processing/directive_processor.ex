defmodule Lye.Processing.DirectiveProcessor do
  @moduledoc """
  The `DirectiveProcessor` parses the assets contents for directives
  and executes those directives. The processed asset will have all
  directive lines removed.
  """
  use Private
  alias Lye.Processor
  alias Lye.Environment
  alias Lye.Asset

  @behaviour Processor
  @directivePattern ~r/^ *(\/\/=|\*=|#=) (?<directive>\w+) (?<args>.+)$/

  def call(asset = %Asset{}, environment = %Environment{}) do
    # Split asset data into lines that contain directives and content lines
    {directives, content} = find_directives(asset.data)

    # Process each directive line
    asset =
      directives
      |> Enum.reduce(asset, &process_directive/2)

    # Compile content lines back into data
    filtered_data = Enum.join(content, "\n")

    # Update asset and enviroment
    updated_asset = %{asset | data: filtered_data}
    updated_environment = environment |> Environment.put_asset(updated_asset)

    # Return
    {updated_asset, updated_environment}
  end

  # Helper functions - need to be tested, but are not part of public API
  private do


    # Take a given String input `data` and split it into a tuple.
    #
    # Each tuple element is a list of String lines.
    #
    # The first tuple element, `directives`, contains all lines matching
    # a directive pattern regular expression.
    #
    # The second tuple element, `other`, contains all remaining lines
    # that made up the original data.
    #
    def find_directives(data) do
      lines = String.split(data, ~r/\R/)
      {directives, other} = lines |> Enum.split_with(&is_directive_line?/1)

      # Return
      {directives, other}
    end


    # Given a `directive`, which is a map, and an `Asset`, invoke the
    # logic that is registered for the given directive symbol.
    def process_directive(directive, asset) do
      case parse_directive_line(directive) do

        %{"directive" => directive_symbol, "args" => args} ->
          IO.puts "* Processing #{directive_symbol} directive with argument '#{args}'"
          case directive_symbol do
            "require" -> %{asset | required: [args | asset.required]}
              _ -> asset
          end

        _ ->
          raise("Invalid directive #{directive}")
      end
    end

    # Determine whether a String line matches a directive pattern regular expression.
    def is_directive_line?(line_of_text) do
      line_of_text =~ @directivePattern
    end

    # Parse a String line that maches the directive regular expression into component parts.
    # Returns a map.
    def parse_directive_line(directive_line) do
      Regex.named_captures(@directivePattern,directive_line)
    end

  end

end
