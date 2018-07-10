defmodule Lye.Asset do
  alias Lye.Asset
  alias Lye.Environment

            # logical path for asset
  defstruct name: "",
            # asset contents as String
            data: "",
            # asset MIME type
            type: "unknown",
            # content type of the output asset
            content_type: "",
            # full path to original file
            source_path: "",
            # current load path for file
            load_path: "",
            # the current asset's URI
            uri: "",
            # custom processor metadata hash
            metadata: %{},
            # set of asset URIs that the Bundler processor should prepend
            required: [],
            # set of asset URIs that should be excluded from :required
            stubbed: [],
            # set of asset URIs that should be compiled alongside this asset
            links: [],
            # A set of asset URIs that should be monitored for caching
            dependencies: [],
            # mime charset for this asset
            charset: "UTF-8",
            # indicate whether the asset has already been compiled or not
            compiled: false

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
    %{
      Asset.new(name)
      | data: File.read!(source_path),
        load_path: load_path,
        type: MIME.from_path(source_path),
        content_type: MIME.from_path(source_path),
        source_path: source_path
    }
  end

  def compile(asset = %Asset{}, environment = %Environment{}) do
    pipeline = Lye.Processing.default_pipeline(environment, asset.type)

    {asset, _enviroment} =
      Enum.reduce(pipeline, {asset, environment}, &Lye.Processing.execute_processor/2)

    %{asset | compiled: true}
  end

  def set_type(asset = %Asset{}, type) do
    %{asset | type: type}
  end

  @doc """
  Generates a fingerprint of the asset.
  The fingerprint is a Base16 encoded string of the MD5 hash of the asset's contents.
  """
  def fingerprint(%Asset{data: data}) do
    :crypto.hash(:md5, data)
    |> Base.encode16(case: :lower)
  end

end
