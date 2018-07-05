defmodule Lye.Processing.BundleProcessor do
  @moduledoc """
  The BundleProcessor takes a single file asset
  and prepends all the required assets to the contents.
  """
  alias Lye.Processing.Processor
  alias Lye.Asset
  alias Lye.Environment

  @behaviour Processor

  def call(asset = %Asset{}, environment = %Environment{}) do

    # Retrieve the Processors for this asset
    asset_processors = Lye.Processing.processors_for(environment, asset.type)

    # Execute all processors
    asset = Enum.reduce(asset_processors, asset, &Lye.Processing.execute_processor/2)

    # Bundle contents
    {asset |> bundle_required(), environment}
  end

  defp bundle_required(asset = %Asset{}) do
    # asset = asset.required |> Enum.reduce(asset, &merge(&1, &2, ))
    asset
  end

  defp merge(dependency, asset = %Asset{data: data, type: type}, environment = %Environment{}) do
    # Find extensions matching the asset's MIME type
    extensions = MIME.extensions(type)

    # For each extension, attempt to load an asset
    asset = Enum.reduce(extensions, asset, fn(extension, asset) ->
      dep = Environment.load(environment, dependency <> "." <> extension)
      merged_data = dep.data <> data
      %{asset | data: merged_data}
    end)

    asset
  end

end
