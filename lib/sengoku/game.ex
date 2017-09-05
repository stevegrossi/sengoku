defmodule Sengoku.Game do
  alias Sengoku.{Tile, Player}

  @min_new_units 3
  @tiles_per_new_unit 3
  @battle_outcomes ~w(attacker defender)a

  def initial_state(:hot_seat) do
    %{
      mode: :hot_seat,
      turn: 0,
      current_player_id: nil,
      players: Player.initial_state(%{active: true}),
      tiles: Tile.initial_state,
      winner_id: nil,
      tokens: %{}
    }
  end
  def initial_state(:online) do
    %{
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
          new_token = random_token(16)
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
        state
      end
    else
      state
    end
  end

  def attack(%{current_player_id: current_player_id} = state, from_id, to_id, outcome \\ nil) do
    from_tile = state.tiles[from_id]
    to_tile = state.tiles[to_id]
    defender_id = to_tile.owner

    if (
      from_tile.units >= 1 &&
      from_tile.owner == current_player_id &&
      defender_id != current_player_id &&
      to_id in from_tile.neighbors
    ) do
      outcome = outcome || Enum.random(@battle_outcomes)
      case outcome do
        :attacker ->
          if state.tiles[to_id].units <= 1 do
            state
            |> update_tile(from_id, :units, &(&1 - 1))
            |> put_tile(to_id, :owner, current_player_id)
            |> put_tile(to_id, :units, 1)
            |> deactivate_player_if_defeated(defender_id)
            |> maybe_declare_winner()
          else
            state
            |> update_tile(to_id, :units, &(&1 - 1))
          end
        :defender ->
          state
          |> update_tile(from_id, :units, &(&1 - 1))
      end
    else
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
      |> update_tile(from_id, :units, &(&1 - count))
      |> update_tile(to_id, :units, &(&1 + count))
      |> end_turn
    else
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
    active_player_ids = get_active_player_ids(state)
    Enum.reduce(active_player_ids, state, fn(player_id, state) ->
      assign_tile(state, player_id)
    end)
  end

  defp assign_tile(state, player_id) do
    claimed_tile_ids =
      state.tiles
      |> filter_tile_ids(fn(tile) -> !is_nil(tile.owner) end)

    available_tile_id =
      state.tiles
      |> filter_tile_ids(fn(tile) ->
           is_nil(tile.owner) && (
             tile.neighbors -- claimed_tile_ids == tile.neighbors
           )
         end)
      |> Enum.random

    put_tile(state, available_tile_id, :owner, player_id)
  end

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

  defp maybe_declare_winner(state) do
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

  defp random_token(length) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, length)
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
end