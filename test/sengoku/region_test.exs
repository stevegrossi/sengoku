defmodule Sengoku.RegionTest do
  use ExUnit.Case, async: true

  alias Sengoku.{Region}

  describe "containing_tile_ids/2" do
    test "returns Regions all of whose tile_ids are in the provided list" do
      state = %{
        regions: %{
          1 => %{value: 1, tile_ids: [1, 2, 3]},
          2 => %{value: 1, tile_ids: [4, 5]},
          3 => %{value: 1, tile_ids: [6, 7, 8]},
          4 => %{value: 1, tile_ids: [9, 10]}
        }
      }

      tile_ids = [1, 4, 5, 6, 7, 8, 10]
      result = Region.containing_tile_ids(state, tile_ids)

      assert result == [
               %{value: 1, tile_ids: [4, 5]},
               %{value: 1, tile_ids: [6, 7, 8]}
             ]
    end
  end
end
