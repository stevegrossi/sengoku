defmodule Sengoku.AI.SmartTest do
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
      }
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
        2 => %Tile{owner: nil, units: 1, neighbors: [1]}
      }
    }
    action = AI.Smart.take_action(state)

    assert action == %{type: "attack", from_id: 1, to_id: 2}
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
      }
    }
    action = AI.Smart.take_action(state)

    assert action == %{type: "end_turn"}
  end
end
