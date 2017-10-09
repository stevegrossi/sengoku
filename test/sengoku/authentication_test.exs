defmodule Sengoku.AuthenticationTest do
  use ExUnit.Case, async: true

  alias Sengoku.{Player}

  describe ".authenticate_player" do

    test "with no token, replaces the first AI player" do
      token = nil
      old_state = %{
        turn: 0,
        players: %{
          1 => %Player{ai: false},
          2 => %Player{ai: true}
        },
        tokens: %{
          "foo" => 1
        }
      }

      assert {:ok, {2, new_token}, new_state} = Authentication.authenticate_player(old_state, token)
      assert new_state.players[2].ai == false
      assert new_state.tokens[new_token] == 2
    end

    test "with no token, prevents adding new players when the game is in progress" do
      token = nil
      old_state = %{
        turn: 1,
        players: %{
          1 => %Player{ai: false},
          2 => %Player{ai: true}
        },
        tokens: %{
          "foo" => 1
        }
      }

      assert {:error, :in_progress} = Authentication.authenticate_player(old_state, token)
    end

    test "with no token, errors when no AI players left" do
      token = nil
      old_state = %{
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

      assert {:error, :full} = Authentication.authenticate_player(old_state, token)
    end

    test "with a token, returns the existing player_id for the token" do
      token = "abcdef"
      old_state = %{
        turn: 0,
        players: %{
          1 => %Player{ai: false},
          2 => %Player{ai: true}
        },
        tokens: %{ token => 1 }
      }

      assert {:ok, {1, ^token}, ^old_state} = Authentication.authenticate_player(old_state, token)
    end
  end
end
