defmodule Sengoku.GameTest do
  use ExUnit.Case, async: true

  alias Sengoku.{Game, Player, Tile}

  describe ".initial_state" do

    test "returns the state for turn 1" do
      state = Game.initial_state

      assert state.turn == 1
      assert state.current_player_id == 1
      assert state.winner_id == nil
    end

    test "makes each player owner of one tile" do
      state = Game.initial_state

      Enum.each(Player.ids, fn(player_id) ->
        assert Enum.count(state.tiles, fn({_id, tile}) ->
          tile.owner == player_id
        end) == 1
      end)
    end

    test "grants Player one 3 unplaced armies" do
      state = Game.initial_state

      assert state.players[1].unplaced_armies == 3
    end
  end

  describe ".begin_turn" do

    test "grants the current player 3 unplaced armies" do
      old_state = %{
        current_player_id: 99,
        players: %{
          99 => %Player{unplaced_armies: 11}
        }
      }

      new_state = old_state |> Game.begin_turn

      assert new_state.players[99].unplaced_armies == 14
    end
  end

  describe ".end_turn" do

    test "increments current_player_id to the next active Player and grants them armies" do
      old_state = %{
        current_player_id: 2,
        turn: 1,
        players: %{
          1 => %Player{active: true, unplaced_armies: 1},
          2 => %Player{active: true, unplaced_armies: 1},
          3 => %Player{active: false, unplaced_armies: 1},
          4 => %Player{active: true, unplaced_armies: 1}
        }
      }

      new_state = old_state |> Game.end_turn

      assert new_state.current_player_id == 4
      assert new_state.players[4].unplaced_armies == 4
    end

    test "when the last Player’s turn ends, starts at 1 and increments turn" do
      old_state = %{
        current_player_id: 4,
        turn: 1,
        players: %{
          1 => %Player{unplaced_armies: 1},
          2 => %Player{unplaced_armies: 1},
          3 => %Player{unplaced_armies: 1},
          4 => %Player{unplaced_armies: 1}
        }
      }

      new_state = old_state |> Game.end_turn

      assert new_state.current_player_id == 1
      assert new_state.players[1].unplaced_armies == 4
      assert new_state.turn == 2
    end
  end

  describe ".place_army" do

    test "moves an army from the Player to the Tile" do
      old_state = %{
        current_player_id: 1,
        players: %{
          1 => %Player{unplaced_armies: 2},
        },
        tiles: %{
          1 => %Tile{owner: 1, armies: 4}
        }
      }

      new_state = old_state |> Game.place_army(1)

      assert new_state.tiles[1].armies == 5
      assert new_state.players[1].unplaced_armies == 1
    end

    test "changes nothing if the Player does not own the Tile" do
      old_state = %{
        current_player_id: 1,
        players: %{
          1 => %Player{unplaced_armies: 2},
        },
        tiles: %{
          1 => %Tile{owner: 99, armies: 4}
        }
      }

      new_state = old_state |> Game.place_army(1)

      assert new_state == old_state
    end

    test "changes nothing if the Player has no unplaced armies" do
      old_state = %{
        current_player_id: 1,
        players: %{
          1 => %Player{unplaced_armies: 0},
        },
        tiles: %{
          1 => %Tile{owner: 1, armies: 4}
        }
      }

      new_state = old_state |> Game.place_army(1)

      assert new_state == old_state
    end
  end

  describe ".attack" do

    test "when the attacker wins, the defender loses an army" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{armies: 2, owner: 1, neighbors: [2]},
          2 => %Tile{armies: 2, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2, :attacker)
      assert new_state.tiles[2].armies == 1
      assert new_state.tiles[1].armies == 2
    end

    test "when the attacker defeats the last defender, captures the territory and moves one army in" do
      old_state = %{
        current_player_id: 1,
        players: %{
          1 => %Player{active: true},
          2 => %Player{active: true}
        },
        tiles: %{
          1 => %Tile{armies: 2, owner: 1, neighbors: [2]},
          2 => %Tile{armies: 1, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2, :attacker)
      assert new_state.tiles[2].armies == 1
      assert new_state.tiles[1].armies == 1
      assert new_state.tiles[2].owner == 1
    end

    test "when the defender loses their last tile, makes them inactive" do
      old_state = %{
        current_player_id: 1,
        players: %{
          1 => %Player{active: true, unplaced_armies: 5},
          2 => %Player{active: true, unplaced_armies: 5}
        },
        tiles: %{
          1 => %Tile{armies: 2, owner: 1, neighbors: [2]},
          2 => %Tile{armies: 1, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2, :attacker)
      assert new_state.tiles[2].owner == 1
      assert new_state.players[2].active == false
      assert new_state.players[2].unplaced_armies == 0
      assert new_state.players[1].active == true
    end

    test "when only one player remains active, they win!" do
      old_state = %{
        winner_id: nil,
        current_player_id: 1,
        players: %{
          1 => %Player{active: true, unplaced_armies: 5},
          2 => %Player{active: true, unplaced_armies: 5}
        },
        tiles: %{
          1 => %Tile{armies: 2, owner: 1, neighbors: [2]},
          2 => %Tile{armies: 1, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2, :attacker)
      assert new_state.players[2].active == false
      assert new_state.players[1].active == true
      assert new_state.winner_id == 1
    end

    test "when the defender wins, the attacker loses an army" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{armies: 2, owner: 1, neighbors: [2]},
          2 => %Tile{armies: 2, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2, :defender)
      assert new_state.tiles[1].armies == 1
      assert new_state.tiles[2].armies == 2
    end

    test "changes nothing if Player has no armies in origin" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{armies: 0, owner: 1, neighbors: [2]},
          2 => %Tile{armies: 1, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2)
      assert new_state == old_state
    end

    test "changes nothing if Player does not own origin" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{armies: 1, owner: 2, neighbors: [2]},
          2 => %Tile{armies: 1, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2)
      assert new_state == old_state
    end

    test "changes nothing if Player owns the destination" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{armies: 1, owner: 1, neighbors: [2]},
          2 => %Tile{armies: 1, owner: 1, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2)
      assert new_state == old_state
    end

    test "changes nothing if the destination is not a neighbor of the origin" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{armies: 1, owner: 1, neighbors: [3]},
          2 => %Tile{armies: 1, owner: 2, neighbors: [3]}
        }
      }

      new_state = Game.attack(old_state, 1, 2)
      assert new_state == old_state
    end
  end
end
