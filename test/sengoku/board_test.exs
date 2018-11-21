defmodule Sengoku.BoardTest do
  use ExUnit.Case, async: true

  alias Sengoku.{Board}

  describe "new/1" do
    test "returns a Board struct with board-specific data" do
      %Board{
        name: "japan",
        players_count: _players_count,
        tiles: _tiles,
        regions: _regions
      } = Board.new("japan")
    end
  end
end
