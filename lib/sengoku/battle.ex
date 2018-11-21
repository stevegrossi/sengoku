defmodule Sengoku.Battle do
  @moduledoc """
  Responsible for the logic of one Player attacking another’s neighboring Tile.
  """

  def decide(attacker_count, defender_count) do
    attacker_rolls =
      attacker_count
      |> min(3)
      |> roll_n_times

    defender_rolls =
      defender_count
      |> min(2)
      |> roll_n_times

    compare_rolls(attacker_rolls, defender_rolls)
  end

  def compare_rolls(a_rolls, d_rolls) do
    compare_rolls(a_rolls, d_rolls, {0, 0})
  end

  def compare_rolls([], _d_rolls, losses) do
    losses
  end

  def compare_rolls(_a_rolls, [], losses) do
    losses
  end

  def compare_rolls([a_hd | a_tl], [d_hd | d_tl], {a_losses, d_losses})
      when a_hd > d_hd do
    compare_rolls(a_tl, d_tl, {a_losses, d_losses + 1})
  end

  def compare_rolls([a_hd | a_tl], [d_hd | d_tl], {a_losses, d_losses})
      when a_hd <= d_hd do
    compare_rolls(a_tl, d_tl, {a_losses + 1, d_losses})
  end

  defp roll_n_times(n) do
    1..n
    |> Enum.map(&roll_die/1)
    |> Enum.sort(&(&1 >= &2))
  end

  defp roll_die(_i) do
    :rand.uniform(6)
  end
end
