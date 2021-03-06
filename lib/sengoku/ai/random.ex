defmodule Sengoku.AI.Random do
  @moduledoc """
  An AI that chooses moves more-or-less randomly.
  A baseline against which to test other AIs.
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
    tile_id =
      state
      |> owned_tile_ids
      |> Enum.random()

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
      count: Enum.random(pending_move.min..pending_move.max)
    }
  end

  defp has_attackable_neighbor?(state) do
    state
    |> tile_ids_with_attackable_neighbors
    |> length > 0
  end

  defp attack(state) do
    tile_with_attackable_neighbor_id =
      state
      |> tile_ids_with_attackable_neighbors
      |> Enum.random()

    attackable_neighbor_id =
      tile_with_attackable_neighbor_id
      |> find_attackable_neighbor_id(state)

    %{
      type: "attack",
      from_id: tile_with_attackable_neighbor_id,
      to_id: attackable_neighbor_id
    }
  end

  defp tile_ids_with_attackable_neighbors(state) do
    state
    |> Tile.filter_ids(fn tile ->
      tile.owner == state.current_player_number && tile.units > 1 &&
        tile.neighbors
        |> Enum.any?(fn neighbor_id ->
          neighbor = state.tiles[neighbor_id]
          neighbor.owner !== state.current_player_number
        end)
    end)
  end

  defp find_attackable_neighbor_id(tile_id, state) do
    state.tiles[tile_id].neighbors
    |> Enum.filter(fn neighbor_id ->
      neighbor = state.tiles[neighbor_id]
      neighbor.owner !== state.current_player_number
    end)
    |> Enum.random()
  end

  defp owned_tile_ids(state) do
    state
    |> Tile.filter_ids(fn tile ->
      tile.owner == state.current_player_number
    end)
  end

  defp end_turn do
    %{type: "end_turn"}
  end

  def can_move?(state) do
    state
    |> tile_ids_with_friendly_neighbors
    |> length > 0
  end

  def move(state) do
    tile_with_friendly_neighbor_id =
      state
      |> tile_ids_with_friendly_neighbors
      |> Enum.random()

    tile_with_friendly_neighbor_units = state.tiles[tile_with_friendly_neighbor_id].units

    friendly_neighbor_id =
      tile_with_friendly_neighbor_id
      |> find_friendly_neighbor_id(state)

    %{
      type: "move",
      from_id: tile_with_friendly_neighbor_id,
      to_id: friendly_neighbor_id,
      count: tile_with_friendly_neighbor_units
    }
  end

  defp tile_ids_with_friendly_neighbors(state) do
    state
    |> Tile.filter_ids(fn tile ->
      tile.owner == state.current_player_number && tile.units > 0 &&
        tile.neighbors
        |> Enum.any?(fn neighbor_id ->
          neighbor = state.tiles[neighbor_id]
          neighbor.owner == state.current_player_number
        end)
    end)
  end

  defp find_friendly_neighbor_id(tile_id, state) do
    state.tiles[tile_id].neighbors
    |> Enum.filter(fn neighbor_id ->
      neighbor = state.tiles[neighbor_id]
      neighbor.owner == state.current_player_number
    end)
    |> Enum.random()
  end
end
