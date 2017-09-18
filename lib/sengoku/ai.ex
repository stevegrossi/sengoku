defmodule Sengoku.AI do

  def take_action(state) do
    cond do
      has_unplaced_units?(state) -> place_unit(state)
      has_vulnerable_neighbor?(state) -> attack(state)
      true -> end_turn()
    end
  end

  defp has_unplaced_units?(state) do
    state.players[state.current_player_id].unplaced_units > 0
  end

  # TODO:
  # - only put units on border
  # - first in vulnerable territories
  # - second where I want to attack
  defp place_unit(state) do
    tile_id =
      state.tiles
      |> filter_tile_ids(fn(tile) -> tile.owner == state.current_player_id end)
      |> Enum.random
    %{type: "place_unit", tile_id: tile_id}
  end

  defp has_vulnerable_neighbor?(state) do
    state
    |> tile_ids_with_vulnerable_neighbors
    |> length > 0
  end

  # TODO:
  # - attack where I have the largest advantage
  # - prefer unowned neighbors
  # - prefer tiles with fewer neighbors
  # - prefer "bottlenecks"
  # - stop before becoming vulnerable myself
  defp attack(state) do
    tile_with_vulnerable_neighbor_id =
      state
      |> tile_ids_with_vulnerable_neighbors
      |> List.first

    vulnerable_neighbor_id =
      tile_with_vulnerable_neighbor_id
      |> find_vulnerable_neighbor_id(state)

    %{
      type: "attack",
      from_id: tile_with_vulnerable_neighbor_id,
      to_id: vulnerable_neighbor_id
    }
  end

  # TODO:
  # - move largest number of units furthest from border toward border
  # - what if multiple borders?
  defp move(state) do
    state
  end

  defp tile_ids_with_vulnerable_neighbors(state) do
    state.tiles
    |> filter_tile_ids(fn(tile) ->
         tile.owner == state.current_player_id &&
         tile.neighbors
         |> Enum.any?(fn(neighbor_id) ->
              neighbor = state.tiles[neighbor_id]

              neighbor.owner !== state.current_player_id &&
              neighbor.units < tile.units
            end)
       end)
  end

  defp find_vulnerable_neighbor_id(tile_id, state) do
    tile = state.tiles[tile_id]
    tile.neighbors
    |> Enum.find(fn(neighbor_id) ->
         neighbor = state.tiles[neighbor_id]

         neighbor.owner !== state.current_player_id &&
         neighbor.units < tile.units
       end)
  end

  defp filter_tile_ids(tiles_map, func) do
    tiles_map
    |> Enum.filter(fn({_id, tile}) -> func.(tile) end)
    |> Enum.into(%{})
    |> Map.keys
  end

  defp end_turn do
    %{type: "end_turn"}
  end
end
