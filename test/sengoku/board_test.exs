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

      assert board.tiles[59].neighbors == [48, 60, 71]
    end

    test "allow specifying additional neighbor mappings" do
      board = Board.new("earth")

      assert 45 in board.tiles[24].neighbors
      assert 24 in board.tiles[45].neighbors
    end
  end
end
