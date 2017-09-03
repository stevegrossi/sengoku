defmodule Sengoku.GameTest do
  use ExUnit.Case, async: true

  alias Sengoku.{Game, Player, Tile}

  describe ".initial_state" do

    test "returns the state before the game begins" do
      state = Game.initial_state

      assert state.turn == 0
      assert state.current_player_id == nil
      assert state.winner_id == nil
    end
  end

  describe ".authenticate_player" do

    test "with no token, registers the next inactive player and makes them active" do
      token = nil
      old_state = %{
        turn: 0,
        players: %{
          1 => %Player{active: true},
          2 => %Player{active: false}
        },
        tokens: %{
          "foo" => 1
        }
      }

      assert {:ok, {2, new_token}, new_state} = Game.authenticate_player(old_state, token)
      assert new_state.players[2].active == true
      assert new_state.tokens[new_token] == 2
    end

    test "with no token, prevents adding new players when the game is in progress" do
      token = nil
      old_state = %{
        turn: 1,
        players: %{
          1 => %Player{active: true},
          2 => %Player{active: false}
        },
        tokens: %{
          "foo" => 1
        }
      }

      assert {:error, :in_progress} = Game.authenticate_player(old_state, token)
    end

    test "with no token, errors when no inactive players" do
      token = nil
      old_state = %{
        turn: 0,
        players: %{
          1 => %Player{active: true},
          2 => %Player{active: true}
        },
        tokens: %{
          "foo" => 1,
          "bar" => 2
        }
      }

      assert {:error, :full} = Game.authenticate_player(old_state, token)
    end

    test "with a token, returns the existing player_id for the token" do
      token = "abcdef"
      old_state = %{
        turn: 0,
        players: %{
          1 => %Player{active: true},
          2 => %Player{active: false}
        },
        tokens: %{ token => 1 }
      }

      assert {:ok, {1, ^token}, ^old_state} = Game.authenticate_player(old_state, token)
    end
  end

  describe ".start_game" do

    test "makes each active player owner of one tile" do
      old_state = %{
        turn: 0,
        players: %{
          1 => %Player{active: true},
          2 => %Player{active: true},
          3 => %Player{active: true},
          4 => %Player{active: false}
        },
        tiles: %{
          1 => %Tile{owner: nil},
          2 => %Tile{owner: nil},
          3 => %Tile{owner: nil},
          4 => %Tile{owner: nil},
          5 => %Tile{owner: nil},
          6 => %Tile{owner: nil},
          7 => %Tile{owner: nil},
          8 => %Tile{owner: nil},
          9 => %Tile{owner: nil},
          10 => %Tile{owner: nil},
          11 => %Tile{owner: nil},
          12 => %Tile{owner: nil},
          13 => %Tile{owner: nil},
          14 => %Tile{owner: nil},
          15 => %Tile{owner: nil},
          16 => %Tile{owner: nil},
          17 => %Tile{owner: nil},
          18 => %Tile{owner: nil},
        }
      }

      new_state = Game.start_game(old_state)

      Enum.each(1..3, fn(player_id) ->
        assert Enum.count(new_state.tiles, fn({_id, tile}) ->
          tile.owner == player_id
        end) == 1
      end)

      assert Enum.count(new_state.tiles, fn({_id, tile}) ->
        tile.owner == 4
      end) == 0
    end

    test "grants Player one 3 unplaced armies" do
      state = Game.initial_state |> Game.start_game

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

    test "when the last active Player’s turn ends, starts at 1 and increments turn" do
      old_state = %{
        current_player_id: 4,
        turn: 1,
        players: %{
          1 => %Player{unplaced_armies: 0, active: false},
          2 => %Player{unplaced_armies: 1, active: true},
          3 => %Player{unplaced_armies: 1, active: true},
          4 => %Player{unplaced_armies: 1, active: true}
        }
      }

      new_state = old_state |> Game.end_turn

      assert new_state.current_player_id == 2
      assert new_state.players[2].unplaced_armies == 4
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
