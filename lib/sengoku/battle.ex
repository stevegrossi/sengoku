defmodule Sengoku.Battle do
  @battle_outcomes ~w(attacker defender)a

  def decide(attackers, defenders) do
    Enum.random(@battle_outcomes)
  end
end
