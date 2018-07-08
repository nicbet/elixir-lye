defmodule Lye.Processing do

  alias Lye.Asset
  alias Lye.Environment

  def debug_pipeline(_env = %Environment{}, _mime_type) do
    []
  end

  def source_pipline(_env = %Environment{}, _mime_type) do
    []
  end

  def default_pipeline(env = %Environment{}, mime_type) do
    default_processors_for(env, mime_type)
  end

  def default_processors_for(env = %Environment{}, mime_type) do
    case bundle_processors_for(env, mime_type) do
      []         -> processors_for(env, mime_type)
      processors -> processors
    end
  end

  def processors_for(env = %Environment{}, mime_type) do
    processors = []

    processors = post_processors_for(env, mime_type) ++ processors
    processors = transform_processors_for(env, mime_type) ++ processors
    processors = pre_processors_for(env, mime_type) ++ processors
    processors = [Lye.Processing.FileLoadProcessor] ++ processors

    processors
  end

  def pre_processors_for(env = %Environment{}, mime_type) do
    case Map.fetch(env.pre_processors, mime_type) do
      {:ok, processors} -> processors
      :error -> []
    end
  end

  def transform_processors_for(env = %Environment{}, mime_type) do
    case Map.fetch(env.transform_processors, mime_type) do
      {:ok, processors} -> processors
      :error -> []
    end
  end

  def post_processors_for(env = %Environment{}, mime_type) do
    case Map.fetch(env.post_processors, mime_type) do
      {:ok, processors} -> processors
      :error -> []
    end
  end

  def compress_processors_for(env = %Environment{}, mime_type) do
    case Map.fetch(env.compress_processors, mime_type) do
      {:ok, processors} -> processors
      :error -> []
    end
  end

  def bundle_processors_for(env = %Environment{}, mime_type) do
    case Map.fetch(env.bundle_processors, mime_type) do
      {:ok, processors} -> processors
      :error -> []
    end
  end

  def execute_processor(processor, {asset = %Asset{}, enviroment = %Environment{}}) do
    IO.puts "  Invoking processor #{processor}"
    processor.call(asset, enviroment)
  end

end
