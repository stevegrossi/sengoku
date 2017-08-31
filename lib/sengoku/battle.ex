defmodule Sengoku.Battle do

  @outcomes ~w(attacker defender)a

  def resolve do
    Enum.random(@outcomes)
  end
end
