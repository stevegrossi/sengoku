defmodule Sengoku.Region do
  @enforce_keys [:value, :tile_ids]
  defstruct [:value, :tile_ids]

  def initialize_state(state, regions) do
    Map.put(state, :regions, regions)
  end

  def containing_tile_ids(%{regions: regions}, tile_ids) do
    regions
    |> Map.values
    |> Enum.filter(fn(region) ->
         region.tile_ids -- tile_ids == []
       end)
  end
  def containing_tile_ids(_, _), do: []

  def stats(board) do
    state =
      %{}
      |> initialize_state(board)
      |> Sengoku.Tile.initialize_state(board)

    Enum.map(state.regions, fn({id, region}) ->
      border_tile_count =
        Enum.count(region.tile_ids, fn(tile_id) ->
          neighbor_ids = state.tiles[tile_id].neighbors
          neighbor_ids -- region.tile_ids != []
        end)
      value_ratio = region.value / border_tile_count
      free_tiles = length(region.tile_ids) - border_tile_count

      {id, region.value, length(region.tile_ids), border_tile_count, free_tiles, value_ratio}
    end)
  end
end
