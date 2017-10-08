defmodule Sengoku.Tile do
  defstruct owner: nil, units: 1, neighbors: []

  def new(neighbors) do
    %__MODULE__{neighbors: neighbors}
  end

  def initialize_state(state) do
    Map.put(state, :tiles, %{
       1 => new([2]),
       2 => new([1, 3, 4]),
       3 => new([2, 4]),
       4 => new([2, 3, 5, 8]),
       5 => new([4, 6, 7, 8]),
       6 => new([5, 7]),
       7 => new([5, 6, 8, 10, 11, 12]),
       8 => new([4, 5, 7, 9, 10]),
       9 => new([8, 10]),
      10 => new([7, 8, 9, 12, 13]),
      11 => new([7, 12]),
      12 => new([7, 10, 11, 13, 14, 15, 16]),
      13 => new([10, 12, 14]),
      14 => new([12, 13, 16, 17]),
      15 => new([12, 16]),
      16 => new([12, 14, 15, 17, 18]),
      17 => new([14, 16, 18, 20, 21, 23]),
      18 => new([16, 17, 19, 20]),
      19 => new([18, 20]),
      20 => new([17, 18, 19, 21, 22]),
      21 => new([17, 20, 22, 23]),
      22 => new([20, 21, 23]),
      23 => new([17, 21, 22, 24]),
      24 => new([23])
    })
  end
end
