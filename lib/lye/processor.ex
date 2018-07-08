defmodule Lye.Processor do
  @moduledoc """
  Processor defines a behaviour that all Processors need to implement
  """

  @doc """
  The main callback, all processors are required to be call-able and transform
  taking an `{Asset, Enviroment}` tuple as input and producing a transformed
  `{Asset, Environment}` tuple as an output.
  """
  @callback call(Lye.Asset.t, Lye.Environment.t) :: {Lye.Asset.t, Lye.Environment.t}
end
