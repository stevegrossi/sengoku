defmodule Sengoku.Game do
  require Logger

  alias Sengoku.{Authentication, Tile, Player, Region, Battle}

  @min_new_units 3
  @tiles_per_new_unit 3
  @initial_state %{
    turn: 0,
    current_player_id: nil,
    winner_id: nil,
  }

  def initialize_state(game_id, %{"board" => board, "players" => players}) do
    @initial_state
    |> Map.put(:id, game_id)
    |> Map.put(:board, board)
    |> Player.initialize_state(String.to_integer(players))
    |> Tile.initialize_state(board)
    |> Authentication.initialize_state
    |> Region.initialize_state(board)
  end

  def start_game(state) do
    if length(Player.active_ids(state)) > 1 do
      state
      |> assign_tiles
      |> increment_turn
      |> setup_first_turn
      |> begin_turn
    else
      Logger.info("Tried to start game without enough players")
      state
    end
  end

  def begin_turn(%{current_player_id: current_player_id} = state) do
    state
    |> grant_new_units(current_player_id)
    |> grant_region_bonuses(current_player_id)
  end

  defp grant_new_units(state, player_id) do
    new_units_count =
      state
      |> Tile.ids_owned_by(player_id)
      |> length
      |> Integer.floor_div(@tiles_per_new_unit)
      |> max(@min_new_units)

    Player.grant_reinforcements(state, player_id, new_units_count)
  end

  defp grant_region_bonuses(state, player_id) do
    owned_tile_ids = Tile.ids_owned_by(state, player_id)
    case Region.containing_tile_ids(state, owned_tile_ids) do
      [] ->
        state
      regions ->
        bonus =
          Enum.reduce(regions, 0, fn(region, acc) ->
            acc + region.value
          end)

        state
        |> Player.grant_reinforcements(player_id, bonus)
    end
  end

  def end_turn(%{current_player_id: current_player_id} = state) do
    active_player_ids = Player.active_ids(state)
    next_player_id = Enum.at(active_player_ids, Enum.find_index(active_player_ids, fn(id) -> id == current_player_id end) + 1)
    case Enum.member?(active_player_ids, next_player_id) do
      true ->
        state
          |> Map.put(:current_player_id, next_player_id)
      false ->
        state
        |> Map.update!(:turn, &(&1 + 1))
        |> Map.put(:current_player_id, hd(active_player_ids))
    end
    |> begin_turn()
  end

  def place_unit(%{current_player_id: current_player_id} = state, tile_id) do
    if current_player(state).unplaced_units > 0 do
      tile = state.tiles[tile_id]

      if tile.owner == current_player_id do
        state
        |> Player.use_reinforcement(current_player_id)
        |> Tile.adjust_units(tile_id, 1)
      else
        Logger.info("Tried to place unit in unowned tile")
        state
      end
    else
      Logger.info("Tried to place unit when you have none")
      state
    end
  end

  def attack(%{current_player_id: current_player_id} = state, from_id, to_id, outcome \\ nil) do
    from_tile = state.tiles[from_id]
    to_tile = state.tiles[to_id]
    defender_id = to_tile.owner
    attacking_units = from_tile.units - 1
    defending_units = to_tile.units

    if (
      attacking_units > 0 &&
      from_tile.owner == current_player_id &&
      defender_id != current_player_id &&
      to_id in from_tile.neighbors
    ) do
      {attacker_losses, defender_losses} =
        outcome || Battle.decide(attacking_units, defending_units)

      state
      |> Tile.adjust_units(from_id, -attacker_losses)
      |> Tile.adjust_units(to_id, -defender_losses)
      |> check_for_capture(from_id, to_id, min(attacking_units, 3))
      |> deactivate_player_if_defeated(defender_id)
      |> check_for_winner()
    else
      state
    end
  end

  defp check_for_capture(state, from_id, to_id, attacking_units) do
    if state.tiles[to_id].units == 0 do
      state
      |> Tile.adjust_units(from_id, -attacking_units)
      |> Tile.set_owner(to_id, state.current_player_id)
      |> Tile.adjust_units(to_id, attacking_units)
    else
      Logger.info("Invalid attack from `#{from_id}` to `#{to_id}`")
      state
    end
  end

  def move(%{current_player_id: current_player_id} = state, from_id, to_id, count) do
    if (
      state.tiles[from_id].owner == current_player_id &&
      state.tiles[to_id].owner == current_player_id &&
      count < state.tiles[from_id].units &&
      from_id in state.tiles[to_id].neighbors
    ) do
      state
      |> Tile.adjust_units(from_id, -count)
      |> Tile.adjust_units(to_id, count)
      |> end_turn
    else
      Logger.info("Invalid move of `#{count}` units from `#{from_id}` to `#{to_id}`")
      state
    end
  end

  defp increment_turn(state) do
    state
    |> Map.update!(:turn, &(&1 + 1))
  end

  defp setup_first_turn(state) do
    state
    |> Map.put(:current_player_id, List.first(Map.keys(state.players)))
  end

  defp assign_tiles(state) do
    player_ids = Player.active_ids(state)
    available_tile_ids = Tile.unowned_ids(state)

    if length(available_tile_ids) >= length(player_ids) do
      state
      |> assign_random_tile_to_each(player_ids)
      |> assign_tiles
    else
      state
    end
  end

  def assign_random_tile_to_each(state, []), do: state
  def assign_random_tile_to_each(state, [player_id | rest]) do
    tile_id =
      state
      |> Tile.unowned_ids
      |> Enum.random

    new_state = Tile.set_owner(state, tile_id, player_id)
    assign_random_tile_to_each(new_state, rest)
  end

  defp deactivate_player_if_defeated(state, nil), do: state
  defp deactivate_player_if_defeated(state, player_id) do
    if Tile.ids_owned_by(state, player_id) == [] do
      Player.deactivate(state, player_id)
    else
      state
    end
  end

  defp check_for_winner(state) do
    active_player_ids = Player.active_ids(state)
    if length(active_player_ids) == 1 do
      state
      |> Map.put(:winner_id, hd(active_player_ids))
    else
      state
    end
  end

  def current_player(state) do
    state.players[state.current_player_id]
  end
end
