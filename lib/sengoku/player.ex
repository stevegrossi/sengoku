defmodule Sengoku.Player do
  defstruct ~w(unplaced_armies)a

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

  def ids do
    Map.keys(initial_state())
  end

  def first_id do
    List.first(ids())
  end
end
