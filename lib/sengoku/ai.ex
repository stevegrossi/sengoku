defmodule Sengoku.AI do
  @moduledoc """
  The common behaviour all AI modules must implement.
  """
  @callback take_action(map) :: %{type: String.t()}
end
