defmodule Sengoku.BattleTest do
  use ExUnit.Case, async: true

  alias Sengoku.{Battle}

  describe ".decide" do
    test "caps losses at 2 with only 2 attackers" do
      {a_losses, d_losses} = Battle.decide(99, 99)
      assert a_losses + d_losses == 2
    end

    test "caps losses at 1 with only 1 attacker" do
      {a_losses, d_losses} = Battle.decide(1, 99)
      assert a_losses + d_losses == 1
    end

    test "caps losses at 1 with only 1 defender" do
      {a_losses, d_losses} = Battle.decide(99, 1)
      assert a_losses + d_losses == 1
    end

    test "caps losses at 1 with only 1 unit on each side" do
      {a_losses, d_losses} = Battle.decide(1, 1)
      assert a_losses + d_losses == 1
    end
  end

  describe ".compare_rolls" do
    test "when the attacker wins 3" do
      assert {0, 2} == Battle.compare_rolls([6, 6, 6], [2, 1])
    end

    test "when the defender wins 2" do
      assert {2, 0} == Battle.compare_rolls([3, 2, 1], [6, 6])
    end

    test "the defender wins draws" do
      assert {2, 0} == Battle.compare_rolls([3, 2, 1], [3, 2])
    end

    test "when the attacker has fewer than the maximum" do
      assert {0, 1} == Battle.compare_rolls([6], [3, 2])
    end

    test "when the defender has fewer than the maximum" do
      assert {1, 0} == Battle.compare_rolls([3, 2, 1], [6])
    end

    test "when the attacker has 0" do
      assert {0, 0} == Battle.compare_rolls([], [6, 6])
    end

    test "when the defender has 0" do
      assert {0, 0} == Battle.compare_rolls([1, 1, 1], [])
    end
  end
end
