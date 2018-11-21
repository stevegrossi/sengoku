defmodule Sengoku.PlayerTest do
  use ExUnit.Case, async: true

  alias Sengoku.Player

  describe "initialize_state/2" do
    test "adds the specified number of players" do
      state = Player.initialize_state(%{}, 3)

      %{
        1 => %Player{},
        2 => %Player{},
        3 => %Player{}
      } = state.players
    end
  end
end
