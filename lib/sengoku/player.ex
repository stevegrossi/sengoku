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

  def ai_ids(state) do
    state
    |> filter_ids(&(&1.ai))
  end

  def active_ids(state) do
    state
    |> filter_ids(&(&1.active))
  end

  defp filter_ids(state, func) do
    state.players
    |> Enum.filter(fn({_id, player}) -> func.(player) end)
    |> Enum.into(%{})
    |> Map.keys
  end
end
