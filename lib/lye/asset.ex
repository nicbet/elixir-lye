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

  def new(name) do
    %Asset{
      name: name
    }
  end

  def new(name, load_path) do
    # Generate the full source path
    source_path = Path.expand(name, load_path)
    # Read asset from disk and set fields
    %{Asset.new(name) |
      data: File.read!(source_path),
      load_path: load_path,
      type: MIME.from_path(source_path),
      content_type: MIME.from_path(source_path),
      source_path: source_path
    }
  end

  def compile(asset = %Asset{}, environment = %Environment{}) do
    pipeline = Lye.Processing.default_pipeline(environment, asset.type)
    {asset, _enviroment} = Enum.reduce(pipeline, {asset, environment}, &Lye.Processing.execute_processor/2)

    %{asset | compiled: true}
  end

  def set_type(asset = %Asset{}, type) do
    %{asset | type: type}
  end

  def fingerprint(%Asset{data: data}) do
    :crypto.hash(:md5, data)
    |> Base.encode16(case: :lower)
  end

end
