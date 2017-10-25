defmodule Mix.Tasks.Regions do
  @moduledoc """
  A mix task provides information about the costs and benefits of controlling
  each region, which can be helpful to ensure balance when designing regions for
  new boards.

  Usage:

    $ mix regions japan
    Region | Value | Tiles | Border Tiles | “Free” Tiles | Value %
    -------|-------|-------|--------------|--------------|--------
         1 |     2 |     4 |            2 |            2 |      1.0
         2 |     2 |     3 |            2 |            1 |      1.0
         3 |     5 |     6 |            5 |            1 |      1.0
         4 |     5 |     5 |            5 |            0 |      1.0
         5 |     3 |     3 |            3 |            0 |      1.0
         6 |     2 |     3 |            2 |            1 |      1.0

  """

  use Mix.Task

  alias Sengoku.{Board}

  @shortdoc "Region stats"
  def run([board]) do
    IO.puts ""
    IO.puts "Region | Value | Tiles | Border Tiles | “Free” Tiles | Value %"
    IO.puts "-------|-------|-------|--------------|--------------|--------"

    Enum.each(stats(board), fn({id, value, tiles_count, border_tiles_count, free_tiles, value_ratio}) ->
      [
        String.pad_leading(Integer.to_string(id), 6),
        String.pad_leading(Integer.to_string(value), 5),
        String.pad_leading(Integer.to_string(tiles_count), 5),
        String.pad_leading(Integer.to_string(border_tiles_count), 12),
        String.pad_leading(Integer.to_string(free_tiles), 12),
        String.pad_leading(Float.to_string(Float.round(value_ratio, 3)), 8)
      ]
      |> Enum.join(" | ")
      |> IO.puts
    end)
    IO.puts ""
  end

  defp stats(board) when is_binary(board) do
    board
    |> Board.new
    |> stats
  end
  defp stats(%Board{} = board) do
    Enum.map(board.regions, fn({id, region}) ->
      border_tile_count =
        Enum.count(region.tile_ids, fn(tile_id) ->
          neighbor_ids = board.tiles[tile_id].neighbors
          neighbor_ids -- region.tile_ids != []
        end)
      value_ratio = region.value / border_tile_count
      free_tiles = length(region.tile_ids) - border_tile_count

      {id, region.value, length(region.tile_ids), border_tile_count, free_tiles, value_ratio}
    end)
  end
end
