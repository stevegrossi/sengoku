defmodule Sengoku.Tile do
  defstruct owner: nil, units: 1, neighbors: []

  def new(neighbors) do
    %__MODULE__{neighbors: neighbors}
  end

  def initialize_state(state, "japan") do
    Map.put(state, :tiles, %{
      1 => new([2]),
      2 => new([1, 3, 4, 5]),
      3 => new([2, 4]),
      4 => new([2, 3, 5, 8]),
      5 => new([2, 4, 6, 7, 8]),
      6 => new([5, 7]),
      7 => new([5, 6, 8, 10, 11]),
      8 => new([4, 5, 7, 9, 10]),
      9 => new([8, 10]),
      10 => new([7, 8, 9, 12, 13]),
      11 => new([7, 12]),
      12 => new([10, 11, 13, 14, 15, 16]),
      13 => new([10, 12, 14]),
      14 => new([12, 13, 16, 17]),
      15 => new([12, 16]),
      16 => new([12, 14, 15, 17, 18]),
      17 => new([14, 16, 18, 20, 21, 23]),
      18 => new([16, 17, 19, 20]),
      19 => new([18, 20]),
      20 => new([17, 18, 19, 21, 22]),
      21 => new([17, 20, 22, 23]),
      22 => new([20, 21, 23]),
      23 => new([17, 21, 22, 24]),
      24 => new([23])
    })
  end
  def initialize_state(state, "earth") do
    state
    |> Map.put(:board, "earth")
    |> Map.put(:tiles, %{
         1 => new([2, 4, 30]),
         2 => new([1, 3, 4, 5]),
         3 => new([2, 5, 6, 24]),
         4 => new([1, 2, 5, 7]),
         5 => new([2, 3, 4, 6, 7, 8]),
         6 => new([3, 5, 8]),
         7 => new([4, 5, 8, 9]),
         8 => new([5, 6, 7, 9]),
         9 => new([7, 8, 10]),
         10 => new([9, 11, 12]),
         11 => new([10, 12, 13]),
         12 => new([10, 11, 13, 18]),
         13 => new([11, 12]),
         14 => new([15, 16, 17]),
         15 => new([14, 17]),
         16 => new([14, 17, 18]),
         17 => new([14, 15, 16, 18, 19, 36]),
         18 => new([12, 16, 17, 19, 20, 21]),
         19 => new([17, 18, 21, 36]),
         20 => new([18, 21, 22, 23]),
         21 => new([18, 19, 20, 23, 26, 36]),
         22 => new([20, 23, 24, 25]),
         23 => new([20, 21, 22, 25, 26]),
         24 => new([3, 22, 25]),
         25 => new([22, 23, 24, 26]),
         26 => new([21, 23, 25, 27, 34, 36]),
         27 => new([26, 28, 34, 35]),
         28 => new([27, 29, 31, 32, 35]),
         29 => new([28, 30, 31]),
         30 => new([1, 29, 31, 32, 33]),
         31 => new([28, 29, 30, 32]),
         32 => new([28, 30, 31, 33, 35]),
         33 => new([30, 32]),
         34 => new([26, 27, 35, 36, 37]),
         35 => new([27, 28, 32, 33, 34, 37, 38]),
         36 => new([17, 19, 21, 26, 34, 37]),
         37 => new([34, 35, 36, 38]),
         38 => new([35, 37, 39]),
         39 => new([38, 40, 41]),
         40 => new([39, 41, 42]),
         41 => new([39, 42]),
         42 => new([40, 41]),
       })
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
