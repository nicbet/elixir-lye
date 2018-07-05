defmodule Lye.Asset do
  alias Lye.Asset
  alias Lye.Environment

  defstruct name: "", # logical path for asset
            data: "", # asset contents as String
            type: "unknown", # asset MIME type
            content_type: "", # content type of the output asset
            source_path: "", # full path to original file
            load_path: "", # current load path for file
            uri: "", # the current asset's URI
            metadata: %{}, # custom processor metadata hash
            required: [], # set of asset URIs that the Bundler processor should prepend
            stubbed: [], # set of asset URIs that should be excluded from :required
            links: [], # set of asset URIs that should be compiled alongside this asset
            dependencies: [], # A set of asset URIs that should be monitored for caching
            charset: "UTF-8", # mime charset for this asset
            compiled: false # indicate whether the asset has already been compiled or not

  def new() do
    %Asset{}
  end

  def new(logical_asset_path, environment = %Environment{}) do
    case Environment.resolve(environment, logical_asset_path) do
      {:ok, full_asset_path} ->

        %Asset{
          name: Path.basename(logical_asset_path),
          data: File.read!(full_asset_path),
          type: MIME.from_path(full_asset_path),
          content_type: MIME.from_path(full_asset_path),
          source_path: full_asset_path,
        }

      _ -> nil
    end
  end

  def process(asset = %Asset{type: mime_type}, environment = %Environment{}) do
    IO.puts("Processing #{asset.name}")

    pipeline = Lye.Processing.default_pipeline(environment, mime_type)
    asset = Enum.reduce(pipeline, asset, &Lye.Processing.execute_processor/2)

    %{asset | compiled: true}
  end

  def fingerprint(%Asset{data: data}) do
    :crypto.hash(:md5, data)
    |> Base.encode16(case: :lower)
  end

end
