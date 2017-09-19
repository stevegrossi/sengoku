defmodule Sengoku.AI do
  @callback take_action(map) :: %{type: String.t}
end
