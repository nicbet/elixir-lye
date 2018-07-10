defmodule Lye.Environment do
  @moduledoc """
  The `Environment` is the core structure in Lye. It holds a copy of all
  assets that are loaded into the environment, and defines all processors
  that are available for a specific asset mime type. When processors transform
  an Asset, that is done within a given environment, and processors return
  an updated environment struct.

  A default `Environment` pre-configured for Phoenix Framework projects is
  available through the `Environment.phoenix/1` function.
  """
  defstruct paths: [],
            asset_map: %{},
            directives: [],
            bundle_processors: %{},
            transform_processors: %{},
            compress_processors: %{},
            pre_processors: %{},
            post_processors: %{},
            entry_points: [],
            root_path: "."

  alias Lye.Environment
  alias Lye.Asset

  # --------------------------------------------------------------------------------
  # API

  @doc """
  Create a new, empty `Environment`
  """
  def new() do
    %Environment{root_path: "."}
  end

  def new(root_path) do
    %Environment{root_path: root_path}
  end

  @doc """
  Generate a pre-configured `Environment` for the `Phoenix` framework.
  """
  def phoenix(root_path \\ ".") do
    Environment.new(root_path)
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
  def append_path(env = %Environment{paths: paths, root_path: root_path}, load_path) do
    %{env | paths: [Path.join(root_path, load_path) | paths]}
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
  Add asset to the assets map
  """
  def put_asset(environment = %Environment{}, asset = %Asset{}) do
    updated_asset_map = Map.put(environment.asset_map, asset.name, asset)
    %{environment | asset_map: updated_asset_map}
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
        {:error, "Ambiguous #{logical_asset_path} found in #{count} load paths!"}
    end
  end

  @doc """
  Load an Asset within the environment
  """
  def load(environment = %Environment{}, asset) when is_bitstring(asset) do
    IO.puts("* Attempting to load #{asset}")

    asset =
      case resolve(environment, asset) do
        {:ok, load_path} ->
          Asset.new(asset, load_path)
          |> Asset.compile(environment)

        {:error, message} ->
          IO.puts("Could not resolve #{asset}: #{message}")
          Asset.new()
      end

    # Insert into the asset_map
    updated_assets = Map.put(environment.asset_map, asset.name, asset)

    # Return
    {asset, %{environment | asset_map: updated_assets}}
  end

  # Helper function for adding processor to map of key -> processor list
  defp add_to_processors_map(map = %{}, key, entry) do
    case Map.fetch(map, key) do
      {:ok, entries} -> [entry | entries] |> Enum.dedup()
      :error -> [entry]
    end
  end
end
