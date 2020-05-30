defmodule Sengoku.AI.SmartTest do
  use ExUnit.Case, async: true

  alias Sengoku.{AI, Player, Tile, Region}

  test "places a unit when unplaced units" do
    state = %{
      current_player_id: 1,
      players: %{
        1 => %Player{unplaced_units: 1, active: true, ai: true},
        2 => %Player{unplaced_units: 0, active: true, ai: true}
      },
      tiles: %{
        1 => %Tile{owner: 1, units: 1, neighbors: [2]},
        2 => %Tile{owner: nil, units: 1, neighbors: [1]}
      },
      regions: %{
        1 => %Region{value: 1, tile_ids: [1]},
        2 => %Region{value: 1, tile_ids: [2]}
      },
      pending_move: nil
    }

    action = AI.Smart.take_action(state)

    assert action == %{type: "place_unit", tile_id: 1}
  end

  test "attacks when a neighbor has fewer units" do
    state = %{
      current_player_id: 1,
      players: %{
        1 => %Player{unplaced_units: 0, active: true, ai: true},
        2 => %Player{unplaced_units: 0, active: true, ai: true}
      },
      tiles: %{
        1 => %Tile{owner: 1, units: 2, neighbors: [2]},
        2 => %Tile{owner: 2, units: 1, neighbors: [1]}
      },
      regions: %{
        1 => %Region{value: 1, tile_ids: [1]},
        2 => %Region{value: 1, tile_ids: [2]}
      },
      pending_move: nil
    }

    action = AI.Smart.take_action(state)

    assert action == %{type: "attack", from_id: 1, to_id: 2}
  end

  test "moves the maximum number of units away from non-border tiles" do
    state = %{
      current_player_id: 1,
      players: %{
        1 => %Player{unplaced_units: 0, active: true, ai: true},
        2 => %Player{unplaced_units: 0, active: true, ai: true}
      },
      tiles: %{
        1 => %Tile{owner: 1, units: 7, neighbors: [2]},
        2 => %Tile{owner: 1, units: 1, neighbors: [1, 3]},
        3 => %Tile{owner: 2, units: 1, neighbors: [2]}
      },
      pending_move: nil
    }

    action = AI.Smart.take_action(state)

    assert action == %{
             type: "move",
             from_id: 1,
             to_id: 2,
             count: 6
           }
  end

  test "makes a required move when necessary" do
    state = %{
      current_player_id: 1,
      players: %{
        1 => %Player{unplaced_units: 0, active: true, ai: true},
        2 => %Player{unplaced_units: 0, active: true, ai: true}
      },
      tiles: %{
        1 => %Tile{owner: 1, units: 0, neighbors: [2]},
        2 => %Tile{owner: 1, units: 5, neighbors: [1, 3]},
        3 => %Tile{owner: 2, units: 1, neighbors: [2]}
      },
      pending_move: %{
        from_id: 2,
        to_id: 1,
        min: 3,
        max: 4
      }
    }

    action = AI.Smart.take_action(state)

    assert action == %{
             type: "move",
             from_id: 2,
             to_id: 1,
             count: 4
           }
  end

  test "ends turn when no other action" do
    state = %{
      current_player_id: 1,
      players: %{
        1 => %Player{unplaced_units: 0, active: true, ai: true},
        2 => %Player{unplaced_units: 0, active: true, ai: true}
      },
      tiles: %{
        1 => %Tile{owner: 1, units: 1, neighbors: [2]},
        2 => %Tile{owner: nil, units: 1, neighbors: [1]}
      },
      pending_move: nil
    }

    action = AI.Smart.take_action(state)

    assert action == %{type: "end_turn"}
  end

  describe "get_preferred_regions/1" do
    test "returns regions sorted by the percentage you control, favoring smaller regions" do
      state = %{
        current_player_id: 1,
        tiles: %{
          1 => %Tile{owner: 1},
          2 => %Tile{owner: 2},
          3 => %Tile{owner: 2},
          4 => %Tile{owner: 1},
          5 => %Tile{owner: 2},
          6 => %Tile{owner: 1},
          7 => %Tile{owner: 1},
          8 => %Tile{owner: 2},
          9 => %Tile{owner: 2}
        },
        regions: %{
          1 => %Region{value: 1, tile_ids: [1, 2, 3]},
          2 => %Region{value: 1, tile_ids: [4, 5]},
          3 => %Region{value: 1, tile_ids: [6, 7, 8, 9]}
        }
      }

      assert AI.Smart.get_preferred_regions(state) == [
               # 2
               %Region{value: 1, tile_ids: [4, 5]},
               # 3
               %Region{value: 1, tile_ids: [6, 7, 8, 9]},
               # 1
               %Region{value: 1, tile_ids: [1, 2, 3]}
             ]
    end
  end
end
