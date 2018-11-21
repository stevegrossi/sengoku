defmodule Sengoku.AI.RandomTest do
  use ExUnit.Case, async: true

  alias Sengoku.{AI, Player, Tile}

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
      required_move: nil
    }

    action = AI.Random.take_action(state)

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
        2 => %Tile{owner: nil, units: 1, neighbors: [1]}
      },
      required_move: nil
    }

    action = AI.Random.take_action(state)

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
      required_move: nil
    }

    action = AI.Random.take_action(state)

    assert %{
             type: "move",
             from_id: _from_id,
             to_id: _to_id,
             count: _count
           } = action
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
      required_move: %{
        from_id: 2,
        to_id: 1,
        min: 3,
        max: 4
      }
    }

    action = AI.Random.take_action(state)

    assert %{
             type: "move",
             from_id: 2,
             to_id: 1,
             count: _count
           } = action
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
      required_move: nil
    }

    action = AI.Random.take_action(state)

    assert action == %{type: "end_turn"}
  end
end
