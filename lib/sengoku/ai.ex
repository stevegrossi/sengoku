defmodule Sengoku.AI do
  alias Sengoku.AI.{Random}

  @callback take_action(map) :: %{type: String.t}

  def select(:random), do: Random
end
