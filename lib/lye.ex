defmodule Lye do
  @moduledoc """
  The main API for Lye.

  This module implements a GenServer with a
  Lye.Environment struct as global state.

  """
  use GenServer
  alias Lye.Environment

  # --------------------------------------------------------------------------------
  # GenServer start_link(_)
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  # GenServer behaviour callbacks
  @impl true
  def init(environment) do
    {:ok, environment}
  end

  # --------------------------------------------------------------------------------
  # GenServer Handlers
  @impl true
  def handle_call({:fetch, asset_path}, _from, environment) do
    case Map.fetch(environment.asset_map, asset_path) do

      :error ->
        IO.puts("** #{asset_path} not cached...")
        updated_environment = environment |> Environment.load(asset_path)
        case Map.fetch(updated_environment.asset_map, asset_path) do
          :error ->
            {:reply, {:error, "Could not load #{asset_path}"}, environment}
          {:ok, asset} ->
            {:reply, asset, updated_environment}
        end

      {:ok, asset} ->
        IO.puts("** Retrieving #{asset_path} from cache!")
        {:reply, asset, environment}
    end
  end

  # --------------------------------------------------------------------------------
  # Public API

  @doc """
  Fetch an asset.
  """
  def fetch_asset(asset) do
    GenServer.call(__MODULE__, {:fetch, asset})
  end

end
