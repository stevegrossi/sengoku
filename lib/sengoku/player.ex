defmodule Sengoku.Player do
  defstruct unplaced_units: 0, active: true, ai: true

  def new(atts \\ %{}) do
    struct(__MODULE__, atts)
  end

  def initial_state(atts \\ %{}) do
    %{
      1 => new(atts),
      2 => new(atts),
      3 => new(atts),
      4 => new(atts)
    }
  end
end
