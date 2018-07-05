defmodule Lye.Environment do
  defstruct paths: [],
            asset_map: %{},
            directives: [],
            bundle_processors: %{},
            transform_processors: %{},
            compress_processors: %{},
            pre_processors: %{},
            post_processors: %{},
            entry_points: []

  alias Lye.Environment
  alias Lye.Asset

  # --------------------------------------------------------------------------------
  # API

  @doc """
  Create a new, empty `Environment`
  """
  def new() do
    %Environment{}
  end

  @doc """
  Generate a pre-configured `Environment` for the `Phoenix` framework.
  """
  def phoenix() do
    Environment.new()
    |> register_preprocessor("application/javascript", Lye.Processing.DirectiveProcessor)
    |> register_bundler("application/javascript", Lye.Processing.BundleProcessor)
    |> register_preprocessor("text/css", Lye.Processing.DirectiveProcessor)
    |> register_bundler("text/css", Lye.Processing.BundleProcessor)
    |> append_path("assets/css")
    |> append_path("assets/js")
    |> append_path("assets/static")
    |> append_path("assets/vendor")
    |> add_entrypoint("app.css")
    |> add_entrypoint("app.js")
  end

  @doc """
  Prepends the load_path to the existing list of paths.
  That is okay since `load_paths/1` returns the reversed list
  """
  def append_path(env = %Environment{paths: paths}, load_path) do

    %{env | paths: [load_path | paths]}
  end

  @doc """
  Retrieve the unique set of load paths for the given Environment
  """
  def load_paths(%Environment{paths: paths}) do
    paths
    |> Enum.reverse()
    |> Enum.uniq()
  end

  @doc """
  Add a new entrypoint to the list of entrypoints
  """
  def add_entrypoint(env = %Environment{entry_points: entry_points}, logical_name) do
    %{env | entry_points: [logical_name | entry_points]}
  end

  @doc """
  Retrieve the unique set of entry points for the given Environment
  """
  def entrypoints(%Environment{entry_points: entry_points}) do
    Enum.uniq(entry_points)
  end

  defp add_to_processors_map(map = %{}, key, entry) do
    case Map.fetch(map, key) do
      {:ok, entries} -> [entry | entries] |> Enum.dedup()
      :error -> [entry]
    end
  end

  @doc """
  Register the given pre-processor with the specified MIME type
  """
  def register_preprocessor(env = %Environment{}, mime_type, processor) do
    updated_processors =
      env.pre_processors
      |> add_to_processors_map(mime_type, processor)

    %{env | pre_processors: put_in(env.pre_processors, [mime_type], updated_processors)}
  end

  @doc """
  Register the given post-processor with the specified MIME type
  """
  def register_postprocessor(env = %Environment{}, mime_type, processor) do
    updated_processors =
      env.post_processors
      |> add_to_processors_map(mime_type, processor)

    %{env | post_processors: put_in(env.post_processors, [mime_type], updated_processors)}
  end

  @doc """
  Associate the given Bundler processor with the specified MIME type
  """
  def register_bundler(env = %Environment{}, mime_type, processor) do
    updated_processors =
      env.bundle_processors
      |> add_to_processors_map(mime_type, processor)

    %{env | bundle_processors: put_in(env.bundle_processors, [mime_type], updated_processors)}
  end

  @doc """
  Register the given Directive processor in the Environment
  """
  def register_directive(env = %Environment{directives: directives}, processor) do
    %{env | directives: [processor | directives]}
  end

  # @doc """
  # Register the given Transformation processor in the Environment for the specified MIME type
  # """
  # def register_transformer(mime_type_in, mime_type_out, processor) do
  #   raise("Not implemented")
  # end

  @doc """
  Associate the given Compression processor with the specified MIME type
  """
  def register_compressor(env = %Environment{}, mime_type, processor) do
    %{env | compress_processors: put_in(env.compress_processors, [mime_type], processor)}
  end

  @doc """
  A shortcut that resolves an asset by the given logical path
  and then creates and processes such Asset.
  """
  def load(environment = %Environment{asset_map: assets}, logical_asset_path) do
    IO.puts("* Attempting to load #{logical_asset_path}")
    asset =
      case resolve(environment, logical_asset_path) do
        {:error, _} ->
          nil
        {:ok, load_path} ->
          full_asset_path = Path.expand(logical_asset_path, load_path)
          IO.puts "* Resolved to #{load_path}/#{logical_asset_path}"
          # Return asset
          %Asset{
            name: logical_asset_path,
            data: File.read!(full_asset_path),
            type: MIME.from_path(full_asset_path),
            content_type: MIME.from_path(full_asset_path),
            source_path: full_asset_path,
          }
      end

    # Insert into the asset_map
    updated_assets = Map.put(assets, logical_asset_path, asset)

    case asset do
      nil -> environment
      _ -> %{environment | asset_map: updated_assets}
    end
   end

  @doc """
  Resolve an Asset given by it's logical name within the Environment
  through the Environment's load paths.
  """
  def resolve(environment = %Environment{}, logical_asset_path) do
    # Search all load paths in the given environment for the asset
    matching_load_paths =
      environment
      |> Environment.load_paths()
      |> Enum.filter(fn lp -> Path.expand(logical_asset_path, lp) |> File.exists?() end)

    case Enum.count(matching_load_paths) do
      0 ->
        {:error, "Could not resolve #{logical_asset_path}"}
      1 ->
        {:ok, List.first(matching_load_paths)}
      count ->
        {:error, "Ambiguous #{logical_asset_path} found in "}
    end
  end

  @doc """
  Processes an Asset - that is, it invokes a Processor pipeline, where
  each processor transforms the asset.
  """
  def process(environment = %Environment{}, asset = %Asset{}) do

  end
end
