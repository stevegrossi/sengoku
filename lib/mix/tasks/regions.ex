defmodule Mix.Tasks.Regions do
  use Mix.Task

  alias Sengoku.Region

  @shortdoc "Region stats"
  def run(_) do
    IO.puts ""
    IO.puts "Region | Value | Tiles | Border Tiles | “Free” Tiles | Value %"
    IO.puts "-------|-------|-------|--------------|--------------|--------"

    Enum.each(Region.stats, fn({id, value, tiles_count, border_tiles_count, free_tiles, value_ratio}) ->
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
end
