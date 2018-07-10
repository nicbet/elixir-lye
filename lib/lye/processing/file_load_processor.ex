defmodule Lye.Processing.FileLoadProcessor do
  @moduledoc """
  The `FileLoadProcessor` loads the contents of a file
  at the given asset's source_path into an `Asset` struct
  data field.
  """
  alias Lye.Processor
  alias Lye.Asset
  alias Lye.Environment

  @behaviour Processor

  @impl true
  def call(asset = %Asset{}, environment = %Environment{}) do
    loaded_asset = %{asset | data: File.read!(asset.source_path)}
    updated_environment = environment |> Environment.put_asset(loaded_asset)
    {loaded_asset, updated_environment}
  end
end
