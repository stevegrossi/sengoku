defmodule Sengoku.AI.Passive do
  @moduledoc """
  An AI that immediately ends its turn as soon as it begins.
  For testing, since this AI can never win.
  """

  @behaviour Sengoku.AI

  def take_action(state), do: %{type: "end_turn"}
end
