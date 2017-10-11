defmodule Sengoku.Region do

  def containing_tile_ids(%{regions: regions}, tile_ids) do
    regions
    |> Map.values
    |> Enum.filter(fn(region) ->
         region.tile_ids -- tile_ids == []
       end)
  end
  def containing_tile_ids(_, _), do: []
end
