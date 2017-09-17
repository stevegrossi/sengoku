defmodule Sengoku.AI do

  def take_action(state) do
    cond do
      has_unplaced_units?(state) -> place_unit(state)
      true -> %{type: "end_turn"}
    end
  end

  defp has_unplaced_units?(state) do
    state.players[state.current_player_id].unplaced_units > 0
  end

  # TODO: place units for attack or defense
  defp place_unit(state) do
    tile_id =
      state.tiles
      |> filter_tile_ids(fn(tile) -> tile.owner == state.current_player_id end)
      |> Enum.random
    %{type: "place_unit", tile_id: tile_id}
  end

  defp filter_tile_ids(tiles_map, func) do
    tiles_map
    |> Enum.filter(fn({_id, tile}) -> func.(tile) end)
    |> Enum.into(%{})
    |> Map.keys
  end
end
