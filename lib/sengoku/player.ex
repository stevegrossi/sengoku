defmodule Sengoku.Player do
  defstruct unplaced_units: 0, active: true, ai: true

  def new(atts \\ %{}) do
    struct(__MODULE__, atts)
  end

  def initialize_state(state) do
    Map.put(state, :players, %{
      1 => new(),
      2 => new(),
      3 => new(),
      4 => new()
    })
  end
end
