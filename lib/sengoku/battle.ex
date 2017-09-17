defmodule Sengoku.Battle do

  @doc """
  Randomly decides whether the attacker or defender wins a battle. The larger
  the force on either side, the more likely that side is to win, but each side
  always has at least a 20% chance.
  """
  def decide(attackers, defenders) do
    if (:rand.uniform() < win_chance(attackers, defenders)) do
      :attacker
    else
      :defender
    end
  end

  def win_chance(attackers, defenders) do
    0.5 + ratio_bonus(attackers / defenders)
    |> max(0.2)
    |> min(0.8)
  end

  defp ratio_bonus(1.0), do: 0
  defp ratio_bonus(ratio) when ratio < 1 do
    -ratio_bonus(1 / ratio)
  end
  defp ratio_bonus(ratio) do
    ratio / (1 + ratio) - 0.5
  end
end
