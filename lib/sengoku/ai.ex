defmodule Sengoku.AI do
  alias Sengoku.AI.{Random, Smart}

  @callback take_action(map) :: %{type: String.t}

  def select(:random), do: Random
  def select(:smart), do: Smart
end
