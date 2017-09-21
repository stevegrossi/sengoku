defmodule Sengoku.Player do
  defstruct unplaced_units: 0, active: false, ai: nil

  def new(atts \\ %{}) do
    struct(__MODULE__, atts)
  end

  def initial_state(atts \\ %{}) do
    %{
      1 => new(Map.merge(atts, %{ai: :smart})),
      2 => new(Map.merge(atts, %{ai: :random})),
      3 => new(Map.merge(atts, %{ai: :random})),
      4 => new(Map.merge(atts, %{ai: :random}))
    }
  end
end
