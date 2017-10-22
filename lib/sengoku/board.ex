defmodule Sengoku.Board do
  defstruct [:players_count]

  def new("japan") do
    %__MODULE__{players_count: 4}
  end
  def new("earth") do
    %__MODULE__{players_count: 6}
  end
end
