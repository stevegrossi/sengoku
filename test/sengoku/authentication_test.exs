defmodule Sengoku.AuthenticationTest do
  use ExUnit.Case, async: true

  alias Sengoku.{Authentication, Player}

  describe "authenticate_player/3" do
    test "with no player_id, replaces the first AI player" do
      old_state = %{
        turn: 0,
        players: %{
          1 => %Player{ai: false},
          2 => %Player{ai: Sengoku.AI.Smart}
        },
        player_ids: %{
          "foo" => 1
        }
      }

      assert {:ok, {2, new_player_id}, new_state} =
               Authentication.authenticate_player(old_state, nil, "Steve")

      assert new_state.players[2].ai == false
      assert new_state.players[2].name == "Steve"
      assert new_state.player_ids[new_player_id] == 2
    end

    test "with no player_id, prevents adding new players when the game is in progress" do
      player_id = nil

      old_state = %{
        turn: 1,
        players: %{
          1 => %Player{ai: false},
          2 => %Player{ai: Sengoku.AI.Smart}
        },
        player_ids: %{
          "foo" => 1
        }
      }

      assert {:error, :in_progress} =
               Authentication.authenticate_player(old_state, player_id, "Steve")
    end

    test "with no player_id, errors when no AI players left" do
      player_id = nil

      old_state = %{
        turn: 0,
        players: %{
          1 => %Player{ai: false},
          2 => %Player{ai: false}
        },
        player_ids: %{
          "foo" => 1,
          "bar" => 2
        }
      }

      assert {:error, :full} = Authentication.authenticate_player(old_state, player_id, "Steve")
    end

    test "with a player_id, returns the existing player_id for the player_id" do
      player_id = "abcdef"

      old_state = %{
        turn: 0,
        players: %{
          1 => %Player{ai: false},
          2 => %Player{ai: Sengoku.AI.Smart}
        },
        player_ids: %{player_id => 1}
      }

      assert {:ok, {1, ^player_id}, ^old_state} =
               Authentication.authenticate_player(old_state, player_id, "Steve")
    end
  end
end
