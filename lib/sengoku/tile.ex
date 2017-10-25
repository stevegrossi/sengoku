defmodule Sengoku.Tile do
  @moduledoc """
  The struct and behavior of the domain-model Tile, which corresponds to a
  controllable territory on the game board.
  """

  defstruct owner: nil, units: 1, neighbors: []

  def new(neighbors) do
    %__MODULE__{neighbors: neighbors}
  end

  def initialize_state(state, tiles) do
    Map.put(state, :tiles, tiles)
  end

  def update_attributes(state, tile_id, %{} = new_atts) do
    update_in(state, [:tiles, tile_id], fn(tile) ->
      Map.merge(tile, new_atts)
    end)
  end

  def ids_owned_by(state, player_id) do
    state
    |> filter_ids(&(&1.owner == player_id))
  end

  def set_owner(state, tile_id, player_id) do
    update_in(state, [:tiles, tile_id], fn(tile) ->
      Map.put(tile, :owner, player_id)
    end)
  end

  def adjust_units(state, tile_id, count) do
    update_in(state, [:tiles, tile_id], fn(tile) ->
      Map.update!(tile, :units, &(&1 + count))
    end)
  end

  def unowned_ids(state) do
    state
    |> filter_ids(&(is_nil(&1.owner)))
  end

  def filter_ids(state, func) do
    state.tiles
    |> Enum.filter(fn({_id, tile}) -> func.(tile) end)
    |> Enum.into(%{})
    |> Map.keys
  end
end
