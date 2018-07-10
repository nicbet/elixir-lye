defmodule Lye.Processing do
  @moduledoc """
  The `Processing` interface provides API
  methods for `Processor` pipelines and
  helper functions to retrieve processors
  defined for specific `Asset` mime types
  in the Environment.
  """
  alias Lye.Asset
  alias Lye.Environment

  @doc """
  The `debug` pipeline is the same as the `default`
  pipeline with the addition that a `SourceMapProcessor`
  is added to the post procesors by default.
  """
  def debug_pipeline(_env = %Environment{}, _mime_type) do
    []
  end

  @doc """

  """
  def source_pipline(_env = %Environment{}, _mime_type) do
    []
  end

  @doc """
  The default pipeline for a given mime type.
  """
  def default_pipeline(env = %Environment{}, mime_type) do
    default_processors_for(env, mime_type)
  end

  @doc """
  The self pipeline for a given mime type
  """
  def self_pipeline(env = %Environment{}, mime_type) do
    processors_for(env, mime_type)
  end

  @doc """
  Returns a list of default processors for a given mime type
  based on the processors registered in the given Environment.
  """
  def default_processors_for(env = %Environment{}, mime_type) do
    case bundle_processors_for(env, mime_type) do
      []         -> processors_for(env, mime_type)
      processors -> processors
    end
  end

  @doc """
  Returns a list of processors for a given mime type
  based on the processors registered in the given Environment.
  """
  def processors_for(env = %Environment{}, mime_type) do
    processors = []

    processors = post_processors_for(env, mime_type) ++ processors
    processors = transform_processors_for(env, mime_type) ++ processors
    processors = pre_processors_for(env, mime_type) ++ processors
    processors = [Lye.Processing.FileLoadProcessor] ++ processors

    processors
  end

  @doc """
  Returns a list of Pre-Processors registered for the given mime type
  in the given Environment.
  """
  def pre_processors_for(env = %Environment{}, mime_type) do
    case Map.fetch(env.pre_processors, mime_type) do
      {:ok, processors} -> processors
      :error -> []
    end
  end

  @doc """
  Returns a list of Transformation Processors registered for the given mime type
  in the given Environment.
  """
  def transform_processors_for(env = %Environment{}, mime_type) do
    case Map.fetch(env.transform_processors, mime_type) do
      {:ok, processors} -> processors
      :error -> []
    end
  end

  @doc """
  Returns a list of Post-Processors registered for the given mime type
  in the given Environment.
  """
  def post_processors_for(env = %Environment{}, mime_type) do
    case Map.fetch(env.post_processors, mime_type) do
      {:ok, processors} -> processors
      :error -> []
    end
  end

  @doc """
  Returns a list of Compression Processors registered for the given mime type
  in the given Environment.
  """
  def compress_processors_for(env = %Environment{}, mime_type) do
    case Map.fetch(env.compress_processors, mime_type) do
      {:ok, processors} -> processors
      :error -> []
    end
  end

  @doc """
  Returns a list of Bundler Processors registered for the given mime type
  in the given Environment.
  """
  def bundle_processors_for(env = %Environment{}, mime_type) do
    case Map.fetch(env.bundle_processors, mime_type) do
      {:ok, processors} -> processors
      :error -> []
    end
  end

  @doc """
  Invoke the given processor on the specified `Asset` within the context
  of the given `Environment`.
  """
  def execute_processor(processor, {asset = %Asset{}, enviroment = %Environment{}}) do
    IO.puts "  Invoking processor #{processor}"
    processor.call(asset, enviroment)
  end

end
