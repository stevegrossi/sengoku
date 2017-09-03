defmodule Sengoku.Player do
  defstruct unplaced_armies: 0, active: false

  def new(unplaced_armies) do
    %__MODULE__{unplaced_armies: unplaced_armies}
  end

  def initial_state do
    %{
      1 => new(0),
      2 => new(0),
      3 => new(0),
      4 => new(0)
    }
  end
end
