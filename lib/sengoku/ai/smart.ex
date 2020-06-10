defmodule Sengoku.AI.Smart do
  @moduledoc """
  An AI that chooses moves procedurally, more-or-less as a human would.
  """

  @behaviour Sengoku.AI

  alias Sengoku.{Game, Tile}

  def take_action(state) do
    cond do
      has_unplaced_units?(state) -> place_unit(state)
      has_pending_move?(state) -> make_pending_move(state)
      has_attackable_neighbor?(state) -> attack(state)
      can_move?(state) -> move(state)
      true -> end_turn()
    end
  end

  defp has_unplaced_units?(state) do
    Game.current_player(state).unplaced_units > 0
  end

  defp place_unit(state) do
    preferred_regions = get_preferred_regions(state)

    tile_id =
      state
      |> owned_border_tile_ids()
      |> sort_tile_ids_by_region_preference(preferred_regions)
      |> List.first()

    %{type: "place_unit", tile_id: tile_id}
  end

  defp has_pending_move?(state) do
    not is_nil(state.pending_move)
  end

  defp make_pending_move(%{pending_move: pending_move}) do
    %{
      type: "move",
      from_id: pending_move.from_id,
      to_id: pending_move.to_id,
      count: pending_move.max
    }
  end

  defp has_attackable_neighbor?(state) do
    state
    |> tile_ids_with_attackable_neighbors()
    |> length > 0
  end

  defp attack(state) do
    preferred_regions = get_preferred_regions(state)

    tile_with_attackable_neighbor_id =
      state
      |> tile_ids_with_attackable_neighbors()
      |> sort_tile_ids_by_region_preference(preferred_regions)
      |> List.first()

    attackable_neighbor_id =
      tile_with_attackable_neighbor_id
      |> find_attackable_neighbor_id(state)

    %{
      type: "attack",
      from_id: tile_with_attackable_neighbor_id,
      to_id: attackable_neighbor_id
    }
  end

  defp tile_ids_with_attackable_neighbors(%{current_player_number: current_player_number} = state) do
    state
    |> Tile.filter_ids(fn tile ->
      Tile.owned_by_player_id?(tile, current_player_number) and tile.units > 1 and
        Enum.any?(tile.neighbors, fn neighbor_id ->
          neighbor = Tile.get(state, neighbor_id)
          !Tile.owned_by_player_id?(tile, neighbor.owner)
        end)
    end)
  end

  defp find_attackable_neighbor_id(tile_id, %{current_player_number: current_player_number} = state) do
    Tile.get(state, tile_id).neighbors
    |> Enum.filter(fn neighbor_id ->
      neighbor = Tile.get(state, neighbor_id)
      !Tile.owned_by_player_id?(neighbor, current_player_number)
    end)
    |> Enum.random()
  end

  defp owned_border_tile_ids(%{current_player_number: current_player_number} = state) do
    state
    |> Tile.filter_ids(fn tile ->
      Tile.owned_by_player_id?(tile, current_player_number) and
        tile.neighbors
        |> Enum.any?(fn neighbor_id ->
          neighbor = Tile.get(state, neighbor_id)
          !Tile.owned_by_player_id?(neighbor, tile.owner)
        end)
    end)
  end

  defp sort_tile_ids_by_region_preference(tile_ids, region_preference) do
    Enum.sort(tile_ids, fn tile_id_1, tile_id_2 ->
      tile_index(region_preference, tile_id_1) < tile_index(region_preference, tile_id_2)
    end)
  end

  defp tile_index(regions, tile_id) do
    Enum.find_index(regions, fn region ->
      tile_id in region.tile_ids
    end)
  end

  # Returns regions sorted by how close you are to owning it
  def get_preferred_regions(%{current_player_number: current_player_number} = state) do
    owned_tile_ids = Tile.ids_owned_by(state, current_player_number)

    state.regions
    |> Enum.sort(fn {_id_1, region_1}, {_id_2, region_2} ->
      length(region_2.tile_ids -- owned_tile_ids) > length(region_1.tile_ids -- owned_tile_ids)
    end)
    |> Enum.map(fn {_id, region} -> region end)
  end

  defp end_turn do
    %{type: "end_turn"}
  end

  def can_move?(state) do
    state
    |> safe_owned_tiles()
    |> length() > 0
  end

  def move(state) do
    safe_owned_tile_id_with_most_units =
      state
      |> safe_owned_tiles()
      |> Enum.max_by(fn tile_id ->
        Tile.get(state, tile_id).units
      end)

    units_in_safe_owned_tile_id_with_most_units =
      Tile.get(state, safe_owned_tile_id_with_most_units).units

    friendly_neighbor_id =
      safe_owned_tile_id_with_most_units
      |> find_friendly_neighbor_id(state)

    %{
      type: "move",
      from_id: safe_owned_tile_id_with_most_units,
      to_id: friendly_neighbor_id,
      count: units_in_safe_owned_tile_id_with_most_units - 1
    }
  end

  defp safe_owned_tiles(state) do
    state
    |> Tile.filter_ids(fn tile ->
      tile.owner == state.current_player_number && tile.units > 1 &&
        tile.neighbors
        |> Enum.all?(fn neighbor_id ->
          neighbor = Tile.get(state, neighbor_id)
          neighbor.owner == state.current_player_number
        end)
    end)
  end

  # TODO: this should prioritize tiles with hostile neighbors
  defp find_friendly_neighbor_id(tile_id, state) do
    Tile.get(state, tile_id).neighbors
    |> Enum.filter(fn neighbor_id ->
      neighbor = Tile.get(state, neighbor_id)
      neighbor.owner == state.current_player_number
    end)
    |> Enum.random()
  end
end
