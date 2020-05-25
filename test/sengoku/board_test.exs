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

    test "restricts neighbors to only tiles on the board" do
      board = Board.new("wheel")

      assert board.tiles[3].neighbors == [4, 12, 13]
    end

    test "allow specifying additional neighbor mappings" do
      board = Board.new("earth")

      assert 10 in board.tiles[19].neighbors
      assert 19 in board.tiles[10].neighbors
    end
  end
end
