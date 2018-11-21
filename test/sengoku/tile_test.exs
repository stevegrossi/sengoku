defmodule Sengoku.TileTest do
  use ExUnit.Case, async: true

  alias Sengoku.{Tile}

  describe "owned_by_player_id?/2" do
    test "should return true if the passed tile is owned by the passed player" do
      tile = %Tile{owner: 1}
      player_id = 1
      assert Tile.owned_by_player_id?(tile, player_id)
    end

    test "should return false if the passed tile is owned by another player" do
      tile = %Tile{owner: 2}
      player_id = 1
      refute Tile.owned_by_player_id?(tile, player_id)
    end

    test "should return false if the passed tile is not owned by anyone" do
      tile = %Tile{}
      player_id = 1
      refute Tile.owned_by_player_id?(tile, player_id)
    end

    test "encodes to JSON" do
      assert Jason.encode!(Tile.new([]))
    end
  end
end
