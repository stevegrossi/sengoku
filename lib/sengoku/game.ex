defmodule Sengoku.Game do
  require Logger

  alias Sengoku.{Tile, Player, Token}

  @min_new_units 3
  @tiles_per_new_unit 3
  @battle_outcomes ~w(attacker defender)a

  def initial_state(game_id, :hot_seat) do
    %{
      id: game_id,
      mode: :hot_seat,
      turn: 0,
      current_player_id: nil,
      players: Player.initial_state(%{active: true}),
      tiles: Tile.initial_state,
      winner_id: nil,
      tokens: %{}
    }
  end
  def initial_state(game_id, :online) do
    %{
      id: game_id,
      mode: :online,
      turn: 0,
      current_player_id: nil,
      players: Player.initial_state(%{active: false}),
      tiles: Tile.initial_state,
      winner_id: nil,
      tokens: %{}
    }
  end

  def start_game(state) do
    active_player_ids = get_active_player_ids(state)
    if Enum.count(active_player_ids) > 1 do
      state
      |> assign_tiles
      |> increment_turn
      |> setup_first_turn
      |> begin_turn
    else
      Logger.warn("Tried to start game without enough players")
      state
    end
  end

  def begin_turn(%{current_player_id: current_player_id} = state) do
    state
    |> grant_new_units(current_player_id)
  end

  defp grant_new_units(state, player_id) do
    new_units_count =
      state.tiles
      |> filter_tile_ids(fn(tile) -> tile.owner == player_id end)
      |> length
      |> Integer.floor_div(@tiles_per_new_unit)
      |> max(@min_new_units)

    state
    |> update_player(player_id, :unplaced_units, &(&1 + new_units_count))
  end

  def authenticate_player(%{mode: :hot_seat} = state, _token) do
    {:ok, {nil, nil}, state}
  end
  def authenticate_player(%{mode: :online} = state, token) do
    existing_player_id = state.tokens[token]

    if existing_player_id do
      {:ok, {existing_player_id, token}, state}
    else
      if state.turn == 0 do
        first_inactive_player_id =
          state
          |> get_inactive_player_ids
          |> List.first

        if is_nil(first_inactive_player_id) do
          {:error, :full}
        else
          new_token = Token.new(16)
          state =
            state
            |> put_in([:tokens, new_token], first_inactive_player_id)
            |> put_player(first_inactive_player_id, :active, true)
          {:ok, {first_inactive_player_id, new_token}, state}
        end
      else
        {:error, :in_progress}
      end
    end
  end

  def end_turn(%{current_player_id: current_player_id} = state) do
    active_player_ids = get_active_player_ids(state)
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
    current_player = state.players[current_player_id]
    if current_player.unplaced_units > 0 do
      tile = state.tiles[tile_id]

      if tile.owner == current_player_id do
        state
        |> update_player(current_player_id, :unplaced_units, &(&1 - 1))
        |> update_tile(tile_id, :units, &(&1 + 1))
      else
        Logger.warn("Tried to place unit in unowned tile")
        state
      end
    else
      Logger.warn("Tried to place unit when you have none")
      state
    end
  end

  def attack(%{current_player_id: current_player_id} = state, from_id, to_id, outcome \\ nil) do
    from_tile = state.tiles[from_id]
    to_tile = state.tiles[to_id]
    defender_id = to_tile.owner

    if (
      from_tile.units > 0 &&
      from_tile.owner == current_player_id &&
      defender_id != current_player_id &&
      to_id in from_tile.neighbors
    ) do
      outcome =
        cond do
          not is_nil(outcome) -> outcome
          state.tiles[to_id].units == 0 -> :attacker
          true -> Enum.random(@battle_outcomes)
        end
      case outcome do
        :attacker ->
          if state.tiles[to_id].units <= 1 do
            state
            |> update_tile(from_id, :units, &(&1 - 1))
            |> put_tile(to_id, :owner, current_player_id)
            |> put_tile(to_id, :units, 1)
            |> deactivate_player_if_defeated(defender_id)
            |> check_for_winner()
          else
            state
            |> update_tile(to_id, :units, &(&1 - 1))
          end
        :defender ->
          state
          |> update_tile(from_id, :units, &(&1 - 1))
      end
    else
      Logger.warn("Invalid attack from `#{from_id}` to `#{to_id}`")
      state
    end
  end

  def move(%{current_player_id: current_player_id} = state, from_id, to_id, count) do
    if (
      state.tiles[from_id].owner == current_player_id &&
      state.tiles[to_id].owner == current_player_id &&
      count <= state.tiles[from_id].units &&
      from_id in state.tiles[to_id].neighbors
    ) do
      state
      |> update_tile(from_id, :units, &(&1 - count))
      |> update_tile(to_id, :units, &(&1 + count))
      |> end_turn
    else
      Logger.warn("Invalid move of `#{count}` units from `#{from_id}` to `#{to_id}`")
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
    player_ids = get_active_player_ids(state)
    available_tile_ids = get_unowned_tile_ids(state)

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
      |> get_unowned_tile_ids
      |> Enum.random

    new_state = put_tile(state, tile_id, :owner, player_id)
    assign_random_tile_to_each(new_state, rest)
  end

  defp deactivate_player_if_defeated(state, nil), do: state
  defp deactivate_player_if_defeated(state, player_id) do
    has_remaining_tiles =
      state.tiles
      |> Map.values
      |> Enum.any?(fn(%Tile{} = tile) -> tile.owner == player_id end)

    if has_remaining_tiles do
      state
    else
      state
      |> put_player(player_id, :active, false)
      |> put_player(player_id, :unplaced_units, 0)
    end
  end

  defp check_for_winner(state) do
    active_player_ids = get_active_player_ids(state)
    if Enum.count(active_player_ids) == 1 do
      state
      |> Map.put(:winner_id, hd(active_player_ids))
    else
      state
    end
  end

  defp put_tile(state, tile_id, key, value) do
    update_in(state, [:tiles, tile_id], fn(%Tile{} = tile) ->
      Map.put(tile, key, value)
    end)
  end

  defp update_tile(state, tile_id, key, func) do
    update_in(state, [:tiles, tile_id], fn(%Tile{} = tile) ->
      Map.update!(tile, key, func)
    end)
  end

  defp put_player(state, player_id, key, value) do
    update_in(state, [:players, player_id], fn(%Player{} = player) ->
      Map.put(player, key, value)
    end)
  end

  defp update_player(state, player_id, key, func) do
    update_in(state, [:players, player_id], fn(%Player{} = player) ->
      Map.update!(player, key, func)
    end)
  end

  defp get_active_player_ids(state) do
    state.players
    |> filter_player_ids(&(&1.active))
  end

  defp get_inactive_player_ids(state) do
    state.players
    |> filter_player_ids(&(not &1.active))
  end

  defp filter_player_ids(players_map, func) do
    players_map
    |> Enum.filter(fn({_id, player}) -> func.(player) end)
    |> Enum.into(%{})
    |> Map.keys
  end

  defp filter_tile_ids(tiles_map, func) do
    tiles_map
    |> Enum.filter(fn({_id, tile}) -> func.(tile) end)
    |> Enum.into(%{})
    |> Map.keys
  end

  def get_unowned_tile_ids(state) do
    state.tiles
    |> filter_tile_ids(&(is_nil(&1.owner)))
  end
end
