defmodule Sengoku.AI do
  @moduledoc """
  The common behaviour all AI modules must implement.
  """

  alias Sengoku.AI.{Random, Smart}

  @callback take_action(map) :: %{type: String.t()}

  def select(:random), do: Random
  def select(:smart), do: Smart
end
