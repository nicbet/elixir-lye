defmodule Lye.Processing.Processor do
  @moduledoc """
  Processor defines a behaviour that all Processors need to implement
  """

  @doc """
  The main callback, all processors are required to be call-able and transform
  taking an `Asset` as an input and producing a transformed `Asset` as an output,
  similar to `Plug` and the `Conn` object.
  """
  @callback call(Lye.Asset.t, Lye.Environment.t) :: {Lye.Asset.t, Lye.Environment.t}
end
