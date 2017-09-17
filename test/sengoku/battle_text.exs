defmodule Sengoku.BattleTest do
  use ExUnit.Case, async: true

  alias Sengoku.{Battle}

  describe ".win_chance" do

    test "returns 0.5 for evenly matched forces" do
      assert Battle.win_chance(1, 1) == 0.5
      assert Battle.win_chance(9, 9) == 0.5
      assert Battle.win_chance(99, 99) == 0.5
    end

    test "favors the attacker when they have more units" do
      assert Battle.win_chance(2, 1) > 0.5
      assert Battle.win_chance(11, 10) > 0.5
      assert Battle.win_chance(100, 3) > 0.5
    end

    test "favors the defender when they have more units" do
      assert Battle.win_chance(1, 2) < 0.5
      assert Battle.win_chance(10, 11) < 0.5
      assert Battle.win_chance(3, 100) < 0.5
    end

    test "favors attackers and defenders equally" do
      assert Battle.win_chance(1, 2) + Battle.win_chance(2, 1) == 1
      assert Battle.win_chance(10, 11) + Battle.win_chance(11, 10) == 1
      assert Battle.win_chance(3, 100) + Battle.win_chance(100, 3) == 1
    end

    test "clamps odds between 20% and 80%" do
      assert Battle.win_chance(1_000, 1) == 0.8
      assert Battle.win_chance(1, 1_000) == 0.2
    end
  end
end
