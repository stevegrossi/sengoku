defmodule Sengoku.Board do
  @moduledoc """
  Holds any and all board-specific data on the server.
  """

  defstruct [:players_count, :regions, :tiles, :name]

  alias Sengoku.{Region, Tile}

  @all_neighbor_ids %{
    1 => [2, 10, 11],
    2 => [1, 3, 11, 12],
    3 => [2, 4, 12, 13],
    4 => [3, 5, 13, 14],
    5 => [4, 6, 14, 15],
    6 => [5, 7, 15, 16],
    7 => [6, 8, 16, 17],
    8 => [7, 9, 17, 18],
    9 => [8, 18, 19],
    10 => [1, 11, 20],
    11 => [1, 2, 19, 12, 20, 21],
    12 => [2, 3, 11, 13, 21, 22],
    13 => [3, 4, 12, 14, 22, 23],
    14 => [4, 5, 13, 15, 23, 24],
    15 => [5, 6, 14, 16, 24, 25],
    16 => [6, 7, 15, 17, 25, 26],
    17 => [7, 8, 16, 18, 26, 27],
    18 => [8, 9, 17, 19, 27, 28],
    19 => [9, 18, 28],
    20 => [10, 11, 21, 29, 30],
    21 => [11, 12, 29, 22, 30, 31],
    22 => [12, 13, 21, 23, 31, 32],
    23 => [13, 14, 22, 24, 32, 33],
    24 => [14, 15, 23, 25, 33, 34],
    25 => [15, 16, 24, 26, 34, 35],
    26 => [16, 17, 25, 27, 35, 36],
    27 => [17, 18, 26, 28, 36, 37],
    28 => [18, 19, 27, 37, 38],
    29 => [20, 30, 39],
    30 => [20, 21, 29, 31, 39, 40],
    31 => [21, 22, 30, 32, 40, 41],
    32 => [22, 23, 31, 33, 41, 42],
    33 => [23, 24, 32, 34, 42, 43],
    34 => [24, 25, 33, 35, 43, 44],
    35 => [25, 26, 34, 36, 44, 45],
    36 => [26, 27, 35, 37, 45, 46],
    37 => [27, 28, 36, 38, 46, 47],
    38 => [28, 37, 47],
    39 => [29, 30, 40, 48, 49],
    40 => [30, 31, 39, 41, 49, 50],
    41 => [31, 32, 40, 42, 50, 51],
    42 => [32, 33, 41, 43, 51, 52],
    43 => [33, 34, 42, 44, 52, 53],
    44 => [34, 35, 43, 45, 53, 54],
    45 => [35, 36, 44, 46, 54, 55],
    46 => [36, 37, 45, 47, 55, 56],
    47 => [37, 38, 46, 56, 57],
    48 => [39, 49, 58],
    49 => [39, 40, 48, 50, 58, 59],
    50 => [40, 41, 49, 51, 59, 60],
    51 => [41, 42, 50, 52, 60, 61],
    52 => [42, 43, 51, 53, 61, 62],
    53 => [43, 44, 52, 54, 62, 63],
    54 => [44, 45, 53, 55, 63, 64],
    55 => [45, 46, 54, 56, 64, 65],
    56 => [46, 47, 55, 57, 65, 66],
    57 => [47, 56, 66],
    58 => [48, 49, 59, 67, 68],
    59 => [49, 50, 58, 60, 68, 69],
    60 => [50, 51, 59, 61, 69, 70],
    61 => [51, 52, 60, 62, 70, 71],
    62 => [52, 53, 61, 63, 71, 72],
    63 => [53, 54, 62, 64, 72, 73],
    64 => [54, 55, 63, 65, 73, 74],
    65 => [55, 56, 64, 66, 74, 75],
    66 => [56, 57, 65, 75, 76],
    67 => [58, 68, 77],
    68 => [58, 59, 67, 69, 77, 78],
    69 => [59, 60, 68, 70, 78, 79],
    70 => [60, 61, 69, 71, 79, 80],
    71 => [61, 62, 70, 72, 80, 81],
    72 => [62, 63, 71, 73, 81, 82],
    73 => [63, 64, 72, 74, 82, 83],
    74 => [64, 65, 73, 75, 83, 84],
    75 => [65, 66, 74, 76, 84, 85],
    76 => [66, 75, 85],
    77 => [67, 68, 78],
    78 => [68, 69, 77, 79],
    79 => [69, 70, 78, 80],
    80 => [70, 71, 79, 81],
    81 => [71, 72, 80, 82],
    82 => [72, 73, 81, 83],
    83 => [73, 74, 82, 84],
    84 => [74, 75, 83, 85],
    85 => [75, 76, 84]
  }

  @doc """
  Returns a Board struct with the data specific to a given board.
  """
  def new("japan") do
    %__MODULE__{
      name: "japan",
      players_count: 4,
      regions: %{
        1 => %Region{value: 2, tile_ids: [60, 61, 71, 72]},
        2 => %Region{value: 2, tile_ids: [62, 63, 74]},
        3 => %Region{value: 5, tile_ids: [39, 40, 41, 50, 51, 52]},
        4 => %Region{value: 4, tile_ids: [53, 54, 64, 65]},
        5 => %Region{value: 3, tile_ids: [55, 66, 67]},
        6 => %Region{value: 2, tile_ids: [32, 33, 43, 44]}
      },
      tiles:
        build_tiles([
          32,
          33,
          39,
          40,
          41,
          43,
          44,
          50,
          51,
          52,
          53,
          54,
          55,
          60,
          61,
          62,
          63,
          64,
          65,
          66,
          67,
          71,
          72,
          74
        ])
    }
  end

  def new("earth") do
    # Alaska <=> Kamchatka
    additional_neighbors = [{24, 45}]

    %__MODULE__{
      name: "earth",
      players_count: 6,
      regions: %{
        # North America
        1 => %Region{value: 5, tile_ids: [24, 25, 26, 36, 37, 38, 48, 49, 60]},
        # South America
        2 => %Region{value: 2, tile_ids: [72, 73, 83, 84]},
        # Africa
        3 => %Region{value: 3, tile_ids: [74, 75, 86, 87, 98, 99]},
        # Europe
        4 => %Region{value: 5, tile_ids: [39, 40, 41, 51, 52, 63, 64]},
        # Asia
        5 => %Region{value: 7, tile_ids: [42, 43, 44, 45, 53, 54, 55, 56, 65, 66, 67, 76, 78]},
        # Australia
        6 => %Region{value: 2, tile_ids: [90, 91, 101, 102]}
      },
      tiles:
        build_tiles(
          [
            24,
            25,
            26,
            36,
            37,
            38,
            39,
            40,
            41,
            42,
            43,
            44,
            45,
            48,
            49,
            51,
            52,
            53,
            54,
            55,
            56,
            60,
            63,
            64,
            65,
            66,
            67,
            72,
            73,
            74,
            75,
            76,
            78,
            83,
            84,
            86,
            87,
            90,
            91,
            98,
            99,
            101,
            102
          ],
          additional_neighbors
        )
    }
  end

  @doc """
  Returns a Board struct with the data specific to a given board.
  """
  def new("wheel") do
    %__MODULE__{
      name: "wheel",
      players_count: 6,
      regions: %{
        1 => %Region{value: 3, tile_ids: [15, 26, 27, 37, 39, 48]},
        2 => %Region{value: 3, tile_ids: [16, 17, 18, 19, 30, 41]},
        3 => %Region{value: 3, tile_ids: [31, 43, 55, 65, 66, 67]},
        4 => %Region{value: 3, tile_ids: [78, 87, 89, 99, 100, 111]},
        5 => %Region{value: 3, tile_ids: [85, 96, 107, 108, 109, 110]},
        6 => %Region{value: 3, tile_ids: [59, 60, 61, 71, 83, 95]},
        7 => %Region{value: 6, tile_ids: [51, 52, 62, 63, 64, 74, 75]}
      },
      tiles:
        build_tiles([
          15,
          16,
          17,
          18,
          19,
          26,
          27,
          30,
          31,
          37,
          39,
          41,
          43,
          48,
          51,
          52,
          55,
          59,
          60,
          61,
          62,
          63,
          64,
          65,
          66,
          67,
          71,
          74,
          75,
          78,
          83,
          85,
          87,
          89,
          95,
          96,
          99,
          100,
          107,
          108,
          109,
          110,
          111
        ])
    }
  end

  def new("europe") do
    %__MODULE__{
      name: "europe",
      players_count: 8,
      regions: %{
        1 => %Region{value: 2, tile_ids: [10, 20, 29, 30]},
        2 => %Region{value: 6, tile_ids: [31, 32, 40, 41, 42, 50, 51]},
        3 => %Region{value: 2, tile_ids: [58, 59, 60, 67, 68, 69, 77, 78]},
        4 => %Region{value: 3, tile_ids: [52, 53, 61, 62, 72, 81]},
        5 => %Region{value: 5, tile_ids: [24, 25, 33, 34, 43, 44]},
        6 => %Region{value: 6, tile_ids: [26, 27, 35, 36, 37, 45, 46]},
        7 => %Region{value: 4, tile_ids: [54, 55, 56, 64, 65, 66, 74, 75, 84]},
        8 => %Region{value: 5, tile_ids: [18, 19, 28, 38, 47, 57]}
      },
      tiles:
        build_tiles([
          10,
          18,
          19,
          20,
          24,
          25,
          26,
          27,
          28,
          29,
          30,
          31,
          32,
          33,
          34,
          35,
          36,
          37,
          38,
          40,
          41,
          42,
          43,
          44,
          45,
          46,
          47,
          50,
          51,
          52,
          53,
          54,
          55,
          56,
          57,
          58,
          59,
          60,
          61,
          62,
          64,
          65,
          66,
          67,
          68,
          69,
          72,
          74,
          75,
          77,
          78,
          81,
          84
        ])
    }
  end

  defp build_tiles(tile_ids_for_map, additional_neighbors \\ []) do
    tile_ids_for_map
    |> Enum.map(fn tile_id ->
      neighbors =
        Enum.filter(@all_neighbor_ids[tile_id], fn neighbor_id ->
          neighbor_id in tile_ids_for_map
        end)

      neighbors = maybe_add_additional_neighbors(tile_id, neighbors, additional_neighbors)

      {tile_id, Tile.new(neighbors)}
    end)
    |> Enum.into(%{})
  end

  defp maybe_add_additional_neighbors(tile_id, neighbors, additional_neighbor_pairs) do
    additional_neighbors =
      Enum.reduce(additional_neighbor_pairs, [], fn pair, acc ->
        case pair do
          {^tile_id, neighbor} ->
            acc ++ [neighbor]

          {neighbor, ^tile_id} ->
            acc ++ [neighbor]

          _ ->
            acc
        end
      end)

    neighbors ++ additional_neighbors
  end
end
