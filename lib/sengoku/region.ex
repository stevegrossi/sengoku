defmodule Sengoku.Region do
  @moduledoc """
  The struct and behavior of the domain-model Region, which is a grouping of
  Tiles on the board, controlling all of which grants a bonus.
  """

  @derive Jason.Encoder
  @enforce_keys [:value, :tile_ids]
  defstruct [:value, :tile_ids]

  def initialize_state(state, regions) do
    Map.put(state, :regions, regions)
  end

  def containing_tile_ids(%{regions: regions}, tile_ids) do
    regions
    |> Map.values()
    |> Enum.filter(fn region ->
      region.tile_ids -- tile_ids == []
    end)
  end

  def containing_tile_ids(_, _), do: []
end
