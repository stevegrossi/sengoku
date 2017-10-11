defmodule Sengoku.Region do
  @enforce_keys [:value, :tile_ids]
  defstruct [:value, :tile_ids]

  def initialize_state(state) do
    Map.put(state, :regions, %{
      1 => %__MODULE__{value: 2, tile_ids: [1, 2, 3, 4]},
      2 => %__MODULE__{value: 2, tile_ids: [5, 6, 7]},
      3 => %__MODULE__{value: 4, tile_ids: [8, 9, 10, 11, 12, 13]},
      4 => %__MODULE__{value: 4, tile_ids: [14, 15, 16, 17, 18]},
      5 => %__MODULE__{value: 3, tile_ids: [19, 20, 21]},
      6 => %__MODULE__{value: 2, tile_ids: [22, 23, 24]}
    })
  end

  def containing_tile_ids(%{regions: regions}, tile_ids) do
    regions
    |> Map.values
    |> Enum.filter(fn(region) ->
         region.tile_ids -- tile_ids == []
       end)
  end
  def containing_tile_ids(_, _), do: []
end
