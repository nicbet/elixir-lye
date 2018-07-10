defmodule Lye.Processing.BundleProcessor do
  @moduledoc """
  The BundleProcessor takes a single file asset
  and prepends all the required assets to the contents.
  """
  alias Lye.Processor
  alias Lye.Asset
  alias Lye.Environment

  @behaviour Processor

  @impl true
  def call(asset = %Asset{}, environment = %Environment{}) do
    IO.puts("--> Executing BundleProcessor on #{asset.name}")
    # Retrieve the Processors for this asset
    asset_processors = Lye.Processing.processors_for(environment, asset.type)

    # Execute all processors
    {updated_asset, updated_environment} =
      Enum.reduce(asset_processors, {asset, environment}, &Lye.Processing.execute_processor/2)

    # Bundle contents
    bundle_required(updated_asset, updated_environment)
  end

  defp bundle_required(asset = %Asset{}, environment = %Environment{}) do
    # For each dependency marked in the required set
    # merge the dependency data into the asset
    asset.required |> Enum.reduce({asset, environment}, &merge/2)
  end

  defp merge(dependency, {asset = %Asset{data: data, type: type}, environment = %Environment{}}) do
    # Find extensions matching the asset's MIME type
    case MIME.extensions(type) |> List.first() do
      nil ->
        {asset, environment}

      extension ->
        {dep, updated_enviroment} = Environment.load(environment, dependency <> "." <> extension)
        merged_data = dep.data <> data
        updated_asset = %{asset | data: merged_data}
        {updated_asset, updated_enviroment}
    end
  end
end
