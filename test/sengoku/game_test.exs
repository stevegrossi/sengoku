defmodule Sengoku.GameTest do
  use ExUnit.Case, async: true

  alias Sengoku.{Game, Player, Tile}

  describe ".initial_state" do

    test "returns the state before the game begins" do
      state = Game.initial_state("123", :hot_seat)

      assert state.mode == :hot_seat
      assert state.turn == 0
      assert state.current_player_id == nil
      assert state.winner_id == nil
    end
  end

  describe ".authenticate_player" do

    test "with no token, replaces the first AI player" do
      token = nil
      old_state = %{
        mode: :online,
        turn: 0,
        players: %{
          1 => %Player{ai: false},
          2 => %Player{ai: true}
        },
        tokens: %{
          "foo" => 1
        }
      }

      assert {:ok, {2, new_token}, new_state} = Game.authenticate_player(old_state, token)
      assert new_state.players[2].ai == false
      assert new_state.tokens[new_token] == 2
    end

    test "with no token, prevents adding new players when the game is in progress" do
      token = nil
      old_state = %{
        mode: :online,
        turn: 1,
        players: %{
          1 => %Player{ai: false},
          2 => %Player{ai: true}
        },
        tokens: %{
          "foo" => 1
        }
      }

      assert {:error, :in_progress} = Game.authenticate_player(old_state, token)
    end

    test "with no token, errors when no AI players left" do
      token = nil
      old_state = %{
        mode: :online,
        turn: 0,
        players: %{
          1 => %Player{ai: false},
          2 => %Player{ai: false}
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
        mode: :online,
        turn: 0,
        players: %{
          1 => %Player{ai: false},
          2 => %Player{ai: true}
        },
        tokens: %{ token => 1 }
      }

      assert {:ok, {1, ^token}, ^old_state} = Game.authenticate_player(old_state, token)
    end
  end

  describe ".start_game" do

    test "randomly and evenly distributes tiles to active players" do
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
          # Ensure one leftover that isn’t assigned:
          10 => %Tile{owner: nil}
        }
      }

      new_state = Game.start_game(old_state)

      Enum.each(1..3, fn(player_id) ->
        assert Enum.count(new_state.tiles, fn({_id, tile}) ->
          tile.owner == player_id
        end) == 3
      end)

      assert Enum.count(new_state.tiles, fn({_id, tile}) ->
        tile.owner == 4
      end) == 0
    end

    test "grants Player one 3 unplaced units" do
      old_state = %{
        turn: 0,
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0},
          3 => %Player{active: true, unplaced_units: 0},
          4 => %Player{active: false, unplaced_units: 0}
        },
        tiles: %{
          1 => %Tile{owner: nil},
          2 => %Tile{owner: nil},
          3 => %Tile{owner: nil},
          4 => %Tile{owner: nil},
          5 => %Tile{owner: nil},
          6 => %Tile{owner: nil}
        }
      }

      new_state = Game.start_game(old_state)
      assert new_state.players[1].unplaced_units == 3
    end

    test "does nothing if only one active player" do
      old_state = %{
        players: %{
          1 => %Player{active: true},
          2 => %Player{active: false},
          3 => %Player{active: false},
          4 => %Player{active: false}
        }
      }

      new_state = Game.start_game(old_state)
      assert new_state == old_state
    end
  end

  describe ".begin_turn" do

    test "grants the current player 1 unit for every 3 owned territories" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{owner: 2},
          2 => %Tile{owner: 1},
          3 => %Tile{owner: 1},
          4 => %Tile{owner: 1},
          5 => %Tile{owner: 1},
          6 => %Tile{owner: 1},
          7 => %Tile{owner: 1},
          8 => %Tile{owner: 1},
          9 => %Tile{owner: 1},
          10 => %Tile{owner: 1},
          11 => %Tile{owner: 1},
          12 => %Tile{owner: 1},
          13 => %Tile{owner: 1},
          14 => %Tile{owner: 1},
          15 => %Tile{owner: 1},
        },
        players: %{
          1 => %Player{unplaced_units: 0}
        }
      }

      new_state = old_state |> Game.begin_turn

      assert new_state.players[1].unplaced_units == 4
    end

    test "grants the current player at least 3 unplaced units" do
      old_state = %{
        current_player_id: 2,
        tiles: %{
          1 => %Tile{owner: 2},
          2 => %Tile{owner: 1},
          3 => %Tile{owner: 1},
          4 => %Tile{owner: 1},
          5 => %Tile{owner: 1},
          6 => %Tile{owner: 1},
          7 => %Tile{owner: 1},
          8 => %Tile{owner: 1},
          9 => %Tile{owner: 1},
          10 => %Tile{owner: 1},
          11 => %Tile{owner: 1},
          12 => %Tile{owner: 1},
          13 => %Tile{owner: 1},
          14 => %Tile{owner: 1},
          15 => %Tile{owner: 1},
        },
        players: %{
          2 => %Player{unplaced_units: 0}
        }
      }

      new_state = old_state |> Game.begin_turn

      assert new_state.players[2].unplaced_units == 3
    end
  end

  describe ".end_turn" do

    test "increments current_player_id to the next active Player and grants them units" do
      old_state = %{
        current_player_id: 2,
        turn: 1,
        players: %{
          1 => %Player{active: true, unplaced_units: 1},
          2 => %Player{active: true, unplaced_units: 1},
          3 => %Player{active: false, unplaced_units: 1},
          4 => %Player{active: true, unplaced_units: 1}
        },
        tiles: %{}
      }

      new_state = old_state |> Game.end_turn

      assert new_state.current_player_id == 4
      assert new_state.players[4].unplaced_units == 4
    end

    test "when the last active Player’s turn ends, starts at 1 and increments turn" do
      old_state = %{
        current_player_id: 4,
        turn: 1,
        players: %{
          1 => %Player{unplaced_units: 0, active: false},
          2 => %Player{unplaced_units: 1, active: true},
          3 => %Player{unplaced_units: 1, active: true},
          4 => %Player{unplaced_units: 1, active: true}
        },
        tiles: %{}
      }

      new_state = old_state |> Game.end_turn

      assert new_state.current_player_id == 2
      assert new_state.players[2].unplaced_units == 4
      assert new_state.turn == 2
    end
  end

  describe ".place_unit" do

    test "moves an unit from the Player to the Tile" do
      old_state = %{
        current_player_id: 1,
        players: %{
          1 => %Player{unplaced_units: 2},
        },
        tiles: %{
          1 => %Tile{owner: 1, units: 4}
        }
      }

      new_state = old_state |> Game.place_unit(1)

      assert new_state.tiles[1].units == 5
      assert new_state.players[1].unplaced_units == 1
    end

    test "changes nothing if the Player does not own the Tile" do
      old_state = %{
        current_player_id: 1,
        players: %{
          1 => %Player{unplaced_units: 2},
        },
        tiles: %{
          1 => %Tile{owner: 99, units: 4}
        }
      }

      new_state = old_state |> Game.place_unit(1)

      assert new_state == old_state
    end

    test "changes nothing if the Player has no unplaced units" do
      old_state = %{
        current_player_id: 1,
        players: %{
          1 => %Player{unplaced_units: 0},
        },
        tiles: %{
          1 => %Tile{owner: 1, units: 4}
        }
      }

      new_state = old_state |> Game.place_unit(1)

      assert new_state == old_state
    end
  end

  describe ".attack" do

    test "when the attacker wins, the defender loses an unit" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{units: 2, owner: 1, neighbors: [2]},
          2 => %Tile{units: 2, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2, :attacker)
      assert new_state.tiles[2].units == 1
      assert new_state.tiles[1].units == 2
    end

    test "when the attacker defeats the last defender, captures the territory and moves one unit in" do
      old_state = %{
        current_player_id: 1,
        players: %{
          1 => %Player{active: true},
          2 => %Player{active: true}
        },
        tiles: %{
          1 => %Tile{units: 2, owner: 1, neighbors: [2]},
          2 => %Tile{units: 1, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2, :attacker)
      assert new_state.tiles[2].units == 1
      assert new_state.tiles[1].units == 1
      assert new_state.tiles[2].owner == 1
    end

    test "when the defender loses their last tile, makes them inactive" do
      old_state = %{
        current_player_id: 1,
        players: %{
          1 => %Player{active: true, unplaced_units: 5},
          2 => %Player{active: true, unplaced_units: 5}
        },
        tiles: %{
          1 => %Tile{units: 2, owner: 1, neighbors: [2]},
          2 => %Tile{units: 1, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2, :attacker)
      assert new_state.tiles[2].owner == 1
      assert new_state.players[2].active == false
      assert new_state.players[2].unplaced_units == 0
      assert new_state.players[1].active == true
    end

    test "does nothing when the last unowned tile is taken" do
      old_state = %{
        current_player_id: 1,
        players: %{
          1 => %Player{active: true, unplaced_units: 5},
        },
        tiles: %{
          1 => %Tile{units: 2, owner: 1, neighbors: [2]},
          2 => %Tile{units: 1, owner: nil, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2, :attacker)
      assert new_state.tiles[2].owner == 1
      assert new_state.players[1].active == true
    end

    test "when only one player remains active, they win!" do
      old_state = %{
        winner_id: nil,
        current_player_id: 1,
        players: %{
          1 => %Player{active: true, unplaced_units: 5},
          2 => %Player{active: true, unplaced_units: 5}
        },
        tiles: %{
          1 => %Tile{units: 2, owner: 1, neighbors: [2]},
          2 => %Tile{units: 1, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2, :attacker)
      assert new_state.players[2].active == false
      assert new_state.players[1].active == true
      assert new_state.winner_id == 1
    end

    test "when the defender wins, the attacker loses an unit" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{units: 2, owner: 1, neighbors: [2]},
          2 => %Tile{units: 2, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2, :defender)
      assert new_state.tiles[1].units == 1
      assert new_state.tiles[2].units == 2
    end

    test "changes nothing if Player has no units in origin" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{units: 0, owner: 1, neighbors: [2]},
          2 => %Tile{units: 1, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2)
      assert new_state == old_state
    end

    test "changes nothing if Player does not own origin" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{units: 1, owner: 2, neighbors: [2]},
          2 => %Tile{units: 1, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2)
      assert new_state == old_state
    end

    test "changes nothing if Player owns the destination" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{units: 1, owner: 1, neighbors: [2]},
          2 => %Tile{units: 1, owner: 1, neighbors: [1]}
        }
      }

      new_state = Game.attack(old_state, 1, 2)
      assert new_state == old_state
    end

    test "changes nothing if the destination is not a neighbor of the origin" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{units: 1, owner: 1, neighbors: [3]},
          2 => %Tile{units: 1, owner: 2, neighbors: [3]}
        }
      }

      new_state = Game.attack(old_state, 1, 2)
      assert new_state == old_state
    end
  end

  describe ".move" do

    test "moves a number of units from one territory to another" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2]},
          2 => %Tile{owner: 1, units: 1, neighbors: [1]},
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0},
        },
      }

      new_state = Game.move(old_state, 1, 2, 5)

      assert new_state.tiles[1].units == 0
      assert new_state.tiles[2].units == 6
    end

    test "ends the Player’s turn" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2]},
          2 => %Tile{owner: 1, units: 1, neighbors: [1]},
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0},
        },
      }

      new_state = Game.move(old_state, 1, 2, 3)
      refute new_state.current_player_id == 1
    end

    test "does nothing if the destination is not a neighbor of the origin" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [3]},
          2 => %Tile{owner: 1, units: 1, neighbors: [3]},
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0},
        },
      }

      new_state = Game.move(old_state, 1, 2, 3)
      assert new_state == old_state
    end

    test "does nothing if the Player does not own the origin" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{owner: 2, units: 5, neighbors: [2]},
          2 => %Tile{owner: 1, units: 1, neighbors: [1]},
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0},
        },
      }

      new_state = Game.move(old_state, 1, 2, 3)
      assert new_state == old_state
    end

    test "does nothing if the Player does not own the destination" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2]},
          2 => %Tile{owner: 2, units: 1, neighbors: [1]},
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0},
        },
      }

      new_state = Game.move(old_state, 1, 2, 3)
      assert new_state == old_state
    end

    test "does nothing if the count is more than the number of units in the origin" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2]},
          2 => %Tile{owner: 1, units: 1, neighbors: [1]},
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0},
        },
      }

      new_state = Game.move(old_state, 1, 2, 6)
      assert new_state == old_state
    end

    test "does nothing if the origin and destination are the same" do
      old_state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2]},
          2 => %Tile{owner: 1, units: 1, neighbors: [1]},
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0},
        },
      }

      new_state = Game.move(old_state, 1, 1, 3)
      assert new_state == old_state
    end
  end
end
