defmodule Sengoku.Region do
  @moduledoc """
  The struct and behavior of the domain-model Region, which is a grouping of
  Tiles on the board, controlling all of which grants a bonus.
  """

  @enforce_keys [:value, :tile_ids]
  defstruct [:value, :tile_ids]

  alias Sengoku.{Region, Tile}

  def initialize_state(state, regions) do
    Map.put(state, :regions, regions)
  end

  @doc """
  Returns regions if their tile_ids are contained in the tile_ids argument.

  Used to return owned regions.
  """
  def containing_tile_ids(%{regions: regions}, tile_ids) do
    regions
    |> Map.values()
    |> Enum.filter(fn region -> has_owner?(region, tile_ids) end)
  end

  def containing_tile_ids(_, _), do: []

  @doc """
  Check if a given region has an owner.

  OBSERVATION: If we stored tiles under regions, we would not need to pass
  tiles here.
  """
  def has_owner?(region, tile_ids) do
    Enum.empty?(region.tile_ids -- tile_ids)
  end
end
