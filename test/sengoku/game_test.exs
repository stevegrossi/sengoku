defmodule Sengoku.GameTest do
  use ExUnit.Case, async: true

  alias Sengoku.{Game, Player, Region, Tile}

  describe "initialize_state/2" do
    test "returns the state before the game begins" do
      state = Game.initialize_state("123", %{"board" => "japan"})

      assert state.turn == 0
      assert state.current_player_number == nil
      assert state.winning_player == nil
    end
  end

  describe "start_game/1" do
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

      Enum.each(1..3, fn player_id ->
        assert Enum.count(new_state.tiles, fn {_id, tile} ->
                 tile.owner == player_id
               end) == 3
      end)

      assert Enum.count(new_state.tiles, fn {_id, tile} ->
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

    # Regions were ownable at game start at and before 4976597
    test "it will not let a player own a region at game start" do
      100
      # Probably easiest to eviscerate simulate_n_game_starts and just run it non-concurrently
      |> simulate_n_game_starts(game_state__tiny_map_with_two_players())
      |> check_games_have_no_region_owners()
    end
  end

  describe "begin_turn/1" do
    test "grants the current player 1 unit for every 3 owned territories" do
      old_state = %{
        current_player_number: 1,
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
          15 => %Tile{owner: 1}
        },
        players: %{
          1 => %Player{unplaced_units: 0}
        }
      }

      new_state = old_state |> Game.begin_turn()

      assert new_state.players[1].unplaced_units == 4
    end

    test "grants the current player at least 3 unplaced units" do
      old_state = %{
        current_player_number: 2,
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
          15 => %Tile{owner: 1}
        },
        players: %{
          2 => %Player{unplaced_units: 0}
        }
      }

      new_state = old_state |> Game.begin_turn()

      assert new_state.players[2].unplaced_units == 3
    end

    test "grants a bonus for owning all tiles in a region" do
      old_state = %{
        current_player_number: 1,
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
          15 => %Tile{owner: 1}
        },
        regions: %{
          1 => %{value: 2, tile_ids: [5, 6, 7, 8]},
          2 => %{value: 3, tile_ids: [1, 2, 3, 4]}
        },
        players: %{
          1 => %Player{unplaced_units: 0}
        }
      }

      new_state = Game.begin_turn(old_state)

      assert new_state.players[1].unplaced_units == 6
    end
  end

  describe "end_turn/1" do
    test "increments current_player_number to the next active Player and grants them units" do
      old_state = %{
        current_player_number: 2,
        selected_tile_id: 1,
        turn: 1,
        players: %{
          1 => %Player{active: true, unplaced_units: 1},
          2 => %Player{active: true, unplaced_units: 1},
          3 => %Player{active: false, unplaced_units: 1},
          4 => %Player{active: true, unplaced_units: 1}
        },
        tiles: %{}
      }

      new_state = old_state |> Game.end_turn()

      assert new_state.current_player_number == 4
      assert new_state.players[4].unplaced_units == 4
      assert new_state.selected_tile_id == nil
    end

    test "when the last active Player’s turn ends, starts at 1 and increments turn" do
      old_state = %{
        current_player_number: 4,
        turn: 1,
        players: %{
          1 => %Player{unplaced_units: 0, active: false},
          2 => %Player{unplaced_units: 1, active: true},
          3 => %Player{unplaced_units: 1, active: true},
          4 => %Player{unplaced_units: 1, active: true}
        },
        tiles: %{}
      }

      new_state = old_state |> Game.end_turn()

      assert new_state.current_player_number == 2
      assert new_state.players[2].unplaced_units == 4
      assert new_state.turn == 2
    end

    test "does nothing when a move is pending" do
      old_state = %{
        current_player_number: 1,
        turn: 1,
        players: %{
          1 => %Player{unplaced_units: 0, active: false},
          2 => %Player{unplaced_units: 1, active: true},
          3 => %Player{unplaced_units: 1, active: true},
          4 => %Player{unplaced_units: 1, active: true}
        },
        tiles: %{},
        pending_move:
          %{
            # Not nil
          }
      }

      new_state = Game.end_turn(old_state)

      assert new_state == old_state
    end
  end

  describe "place_unit/2" do
    test "moves a unit from the Player to the Tile" do
      old_state = %{
        current_player_number: 1,
        players: %{
          1 => %Player{unplaced_units: 2}
        },
        tiles: %{
          1 => %Tile{owner: 1, units: 4}
        },
        pending_move: nil
      }

      new_state = old_state |> Game.place_unit(1)

      assert new_state.tiles[1].units == 5
      assert new_state.players[1].unplaced_units == 1
    end

    test "changes nothing if the Player does not own the Tile" do
      old_state = %{
        current_player_number: 1,
        players: %{
          1 => %Player{unplaced_units: 2}
        },
        tiles: %{
          1 => %Tile{owner: 99, units: 4}
        },
        pending_move: nil
      }

      new_state = old_state |> Game.place_unit(1)

      assert new_state == old_state
    end

    test "changes nothing if the Player has no unplaced units" do
      old_state = %{
        current_player_number: 1,
        players: %{
          1 => %Player{unplaced_units: 0}
        },
        tiles: %{
          1 => %Tile{owner: 1, units: 4}
        },
        pending_move: nil
      }

      new_state = old_state |> Game.place_unit(1)

      assert new_state == old_state
    end

    test "changes nothing if a move is pending" do
      old_state = %{
        current_player_number: 1,
        players: %{
          1 => %Player{unplaced_units: 2}
        },
        tiles: %{
          1 => %Tile{owner: 1, units: 4}
        },
        pending_move:
          %{
            # Not nil
          }
      }

      new_state = old_state |> Game.place_unit(1)

      assert new_state == old_state
    end
  end

  describe "attack/4" do
    test "attackers and defenders lose units" do
      old_state = %{
        current_player_number: 1,
        players: %{
          1 => %Player{active: true},
          2 => %Player{active: true}
        },
        tiles: %{
          1 => %Tile{units: 3, owner: 1, neighbors: [2]},
          2 => %Tile{units: 2, owner: 2, neighbors: [1]}
        },
        pending_move: nil
      }

      new_state = Game.attack(old_state, 1, 2, {1, 1})
      assert new_state.tiles[1].units == 2
      assert new_state.tiles[2].units == 1
    end

    test "when the attacker defeats the last defender, captures the territory and moves the attacking number of units in" do
      old_state = %{
        current_player_number: 1,
        selected_tile_id: 1,
        players: %{
          1 => %Player{active: true},
          2 => %Player{active: true}
        },
        tiles: %{
          1 => %Tile{units: 3, owner: 1, neighbors: [2]},
          2 => %Tile{units: 2, owner: 2, neighbors: [1]}
        },
        pending_move: nil
      }

      new_state = Game.attack(old_state, 1, 2, {0, 2})
      assert new_state.tiles[1].units == 1
      assert new_state.tiles[2].units == 2
      assert new_state.tiles[2].owner == 1
      assert is_nil(new_state.selected_tile_id)
    end

    test "with more units in the origin tile, requires moving some in" do
      old_state = %{
        current_player_number: 1,
        players: %{
          1 => %Player{active: true},
          2 => %Player{active: true}
        },
        tiles: %{
          1 => %Tile{units: 21, owner: 1, neighbors: [2]},
          2 => %Tile{units: 1, owner: 2, neighbors: [1]}
        },
        pending_move: nil
      }

      new_state = Game.attack(old_state, 1, 2, {0, 1})
      assert new_state.tiles[1].units == 21
      assert new_state.tiles[2].units == 0
      assert new_state.tiles[2].owner == 1

      assert new_state.pending_move == %{
               from_id: 1,
               to_id: 2,
               min: 3,
               max: 20,
               required: true
             }
    end

    test "when the defender loses their last tile, makes them inactive" do
      old_state = %{
        current_player_number: 1,
        players: %{
          1 => %Player{active: true, unplaced_units: 5},
          2 => %Player{active: true, unplaced_units: 5}
        },
        tiles: %{
          1 => %Tile{units: 2, owner: 1, neighbors: [2]},
          2 => %Tile{units: 1, owner: 2, neighbors: [1]}
        },
        pending_move: nil
      }

      new_state = Game.attack(old_state, 1, 2, {0, 1})
      assert new_state.tiles[2].owner == 1
      assert new_state.players[2].active == false
      assert new_state.players[2].unplaced_units == 0
      assert new_state.players[1].active == true
    end

    test "when only one player remains active, they win!" do
      old_state = %{
        winning_player: nil,
        current_player_number: 1,
        players: %{
          1 => %Player{active: true, unplaced_units: 5},
          2 => %Player{active: true, unplaced_units: 5}
        },
        tiles: %{
          1 => %Tile{units: 2, owner: 1, neighbors: [2]},
          2 => %Tile{units: 1, owner: 2, neighbors: [1]}
        },
        pending_move: nil
      }

      new_state = Game.attack(old_state, 1, 2, {0, 1})
      assert new_state.players[2].active == false
      assert new_state.players[1].active == true
      assert new_state.winning_player == 1
    end

    test "changes nothing if Player has 1 unit in origin" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{units: 1, owner: 1, neighbors: [2]},
          2 => %Tile{units: 1, owner: 2, neighbors: [1]}
        },
        pending_move: nil
      }

      new_state = Game.attack(old_state, 1, 2)
      assert new_state == old_state
    end

    test "changes nothing if Player does not own origin" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{units: 1, owner: 2, neighbors: [2]},
          2 => %Tile{units: 1, owner: 2, neighbors: [1]}
        },
        pending_move: nil
      }

      new_state = Game.attack(old_state, 1, 2)
      assert new_state == old_state
    end

    test "changes nothing if Player owns the destination" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{units: 1, owner: 1, neighbors: [2]},
          2 => %Tile{units: 1, owner: 1, neighbors: [1]}
        },
        pending_move: nil
      }

      new_state = Game.attack(old_state, 1, 2)
      assert new_state == old_state
    end

    test "changes nothing if the destination is not a neighbor of the origin" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{units: 1, owner: 1, neighbors: [3]},
          2 => %Tile{units: 1, owner: 2, neighbors: [3]}
        },
        pending_move: nil
      }

      new_state = Game.attack(old_state, 1, 2)
      assert new_state == old_state
    end

    test "changes nothing if a move is pending" do
      old_state = %{
        current_player_number: 1,
        players: %{
          1 => %Player{active: true},
          2 => %Player{active: true}
        },
        tiles: %{
          1 => %Tile{units: 3, owner: 1, neighbors: [2]},
          2 => %Tile{units: 2, owner: 2, neighbors: [1]}
        },
        pending_move:
          %{
            # Not nil
          }
      }

      new_state = Game.attack(old_state, 1, 2, {1, 1})
      assert new_state == old_state
    end
  end

  describe "start_move/3" do
    test "starts a non-required move" do
      old_state = %{
        selected_tile_id: 1,
        pending_move: nil,
        players: %{
          1 => %Player{active: true},
          2 => %Player{active: true}
        },
        tiles: %{
          1 => %Tile{units: 3, owner: 1, neighbors: [2]},
          2 => %Tile{units: 2, owner: 2, neighbors: [1]}
        }
      }

      new_state = Game.start_move(old_state, 1, 2)

      assert new_state.pending_move == %{
               from_id: 1,
               to_id: 2,
               min: 1,
               max: 2,
               required: false
             }
    end
  end

  describe "move/4" do
    test "moves a number of units from one territory to another and clears selection" do
      old_state = %{
        current_player_number: 1,
        selected_tile_id: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2]},
          2 => %Tile{owner: 1, units: 1, neighbors: [1]}
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0}
        },
        pending_move: nil
      }

      new_state = Game.move(old_state, 1, 2, 4)

      assert new_state.tiles[1].units == 1
      assert new_state.tiles[2].units == 5
      assert new_state.selected_tile_id == nil
    end

    test "ends the Player’s turn when pending_move.end_turn is true" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2]},
          2 => %Tile{owner: 1, units: 1, neighbors: [1]}
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0}
        },
        pending_move: %{
          from_id: 1,
          to_id: 2,
          min: 3,
          max: 4,
          required: false
        }
      }

      new_state = Game.move(old_state, 1, 2, 3)
      refute new_state.current_player_number == 1
    end

    test "does nothing if the destination is not a neighbor of the origin" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [3]},
          2 => %Tile{owner: 1, units: 1, neighbors: [3]}
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0}
        },
        pending_move: nil
      }

      new_state = Game.move(old_state, 1, 2, 3)
      assert new_state == old_state
    end

    test "does nothing if the Player does not own the origin" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{owner: 2, units: 5, neighbors: [2]},
          2 => %Tile{owner: 1, units: 1, neighbors: [1]}
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0}
        },
        pending_move: nil
      }

      new_state = Game.move(old_state, 1, 2, 3)
      assert new_state == old_state
    end

    test "does nothing if the Player does not own the destination" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2]},
          2 => %Tile{owner: 2, units: 1, neighbors: [1]}
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0}
        },
        pending_move: nil
      }

      new_state = Game.move(old_state, 1, 2, 3)
      assert new_state == old_state
    end

    test "does nothing if the count is more than the number of units in the origin" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2]},
          2 => %Tile{owner: 1, units: 1, neighbors: [1]}
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0}
        },
        pending_move: nil
      }

      new_state = Game.move(old_state, 1, 2, 6)
      assert new_state == old_state
    end

    test "does nothing if at least one unit won’t be left in the origin" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2]},
          2 => %Tile{owner: 1, units: 1, neighbors: [1]}
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0}
        },
        pending_move: nil
      }

      new_state = Game.move(old_state, 1, 2, 5)
      assert new_state == old_state
    end

    test "does nothing if the origin and destination are the same" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2]},
          2 => %Tile{owner: 1, units: 1, neighbors: [1]}
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0}
        },
        pending_move: nil
      }

      new_state = Game.move(old_state, 1, 1, 3)
      assert new_state == old_state
    end

    test "required moves do not end turn" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2]},
          2 => %Tile{owner: 1, units: 0, neighbors: [1]}
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0}
        },
        pending_move: %{
          from_id: 1,
          to_id: 2,
          min: 3,
          max: 4,
          required: true
        }
      }

      new_state = Game.move(old_state, 1, 2, 3)

      assert new_state.tiles[1].units == 2
      assert new_state.tiles[2].units == 3
      assert is_nil(new_state.pending_move)
      assert new_state.current_player_number == 1
    end

    test "required moves enforce the minimum" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2]},
          2 => %Tile{owner: 1, units: 0, neighbors: [1]}
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0}
        },
        pending_move: %{
          from_id: 1,
          to_id: 2,
          min: 3,
          max: 4,
          required: true
        }
      }

      new_state = Game.move(old_state, 1, 2, 2)
      assert new_state == old_state
    end

    test "required moves do not allow moves from other origins" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2, 3]},
          2 => %Tile{owner: 1, units: 0, neighbors: [1, 3]},
          3 => %Tile{owner: 1, units: 5, neighbors: [1, 2]}
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0}
        },
        pending_move: %{
          from_id: 1,
          to_id: 2,
          min: 3,
          max: 4,
          required: true
        }
      }

      new_state = Game.move(old_state, 3, 2, 3)
      assert new_state == old_state
    end

    test "required moves do not allow moves to other destinations" do
      old_state = %{
        current_player_number: 1,
        tiles: %{
          1 => %Tile{owner: 1, units: 5, neighbors: [2, 3]},
          2 => %Tile{owner: 1, units: 0, neighbors: [1]},
          3 => %Tile{owner: 1, units: 2, neighbors: [1]}
        },
        players: %{
          1 => %Player{active: true, unplaced_units: 0},
          2 => %Player{active: true, unplaced_units: 0}
        },
        pending_move: %{
          from_id: 1,
          to_id: 2,
          min: 3,
          max: 4,
          required: true
        }
      }

      new_state = Game.move(old_state, 1, 3, 3)
      assert new_state == old_state
    end
  end

  describe "cancel_move/1" do
    test "removes the pending move, clearing the selection and resuming the player’s turn" do
      old_state = %{
        current_player_number: 1,
        selected_tile_id: 1,
        pending_move: %{
          required: false
        }
      }

      new_state = Game.cancel_move(old_state)

      assert is_nil(new_state.pending_move)
      assert old_state.current_player_number == new_state.current_player_number
      assert is_nil(new_state.selected_tile_id)
    end

    test "does nothing if no move is pending" do
      old_state = %{
        current_player_number: 1,
        selected_tile_id: 1,
        pending_move: nil
      }

      new_state = Game.cancel_move(old_state)

      assert old_state == new_state
    end

    test "does nothing if the pending move is required" do
      old_state = %{
        current_player_number: 1,
        selected_tile_id: 1,
        pending_move: %{
          required: true
        }
      }

      new_state = Game.cancel_move(old_state)

      assert old_state == new_state
    end
  end

  @doc """
  Returns a list of resultant game states for n game starts
  """
  defp simulate_n_game_starts(n, initial_state) when is_integer(n) do
    1..n
    |> Task.async_stream(fn _simulation_number -> Game.start_game(initial_state) end)
    |> Enum.map(fn {:ok, resultant_state} -> resultant_state end)
  end

  @doc """
  Verify that a list of game states contains no game state with a region owner
  """
  defp check_games_have_no_region_owners([%{regions: regions} | _t] = games) do
    region_tile_ids = Enum.map(regions, fn {_key, region} -> region.tile_ids end)
    # assert games.
    # look through the games, get players from each game, get owned_tile_ids from each player

    player_owned_tile_ids =
      Enum.map(games, fn %{players: players} ->
        Enum.map(players, fn player -> player.owned_tile_ids end)
      end)

    assert region_tile_ids == player_owned_tile_ids
    # regions are in the game state map
    # how to check an owner?
    # Tile.ids_owned_by
    # Check the intersection of ids_owned_by and region struct's tile_ids?
    # go over each region
  end

  @doc """
  Verify that a game state contains no region owner
  """
  defp check_game_has_no_region_owner(%{regions: regions, players: players, tiles: tiles}) do
    # !Enum.any?(regions, fn (region) -> Region.has_owner?)
  end


  @doc """
  A game state designed to evoke region-owning by a player at game start.
  """
  defp game_state__tiny_map_with_two_players do
    %{
      turn: 0,
      tiles: %{
        1 => %Tile{owner: nil},
        2 => %Tile{owner: nil},
        3 => %Tile{owner: nil},
        4 => %Tile{owner: nil},
        5 => %Tile{owner: nil}
      },
      regions: %{
        1 => %{value: 2, tile_ids: [1, 2, 3]},
        2 => %{value: 1, tile_ids: [4, 5]}
      },
      players: %{
        1 => %Player{active: true},
        2 => %Player{active: true}
      }
    }
  end
end
