defmodule Sengoku.Game do
  alias Sengoku.{Tile, Player}

  @min_additional_armies 3
  @battle_outcomes ~w(attacker defender)a

  def initial_state do
    %{
      turn: 0,
      current_player_id: nil,
      players: Player.initial_state,
      tiles: Tile.initial_state,
      winner_id: nil
    }
  end

  def start_game(state) do
    state
    |> assign_tiles
    |> increment_turn
    |> setup_first_turn
    |> begin_turn
  end

  def begin_turn(%{current_player_id: current_player_id} = state) do
    state
    |> update_player(current_player_id, :unplaced_armies, &(&1 + @min_additional_armies))
  end

  def game_open?(state) do
    state.turn == 0
  end

  def end_turn(%{current_player_id: current_player_id} = state) do
    active_player_ids =
      state.players
      |> Enum.filter(fn({_id, player}) -> player.active end)
      |> Enum.into(%{})
      |> Map.keys

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

  def place_army(%{current_player_id: current_player_id} = state, tile_id) do
    current_player = state.players[current_player_id]
    if current_player.unplaced_armies > 0 do
      tile = state.tiles[tile_id]

      if tile.owner == current_player_id do
        state
        |> update_player(current_player_id, :unplaced_armies, &(&1 - 1))
        |> update_tile(tile_id, :armies, &(&1 + 1))
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
      from_tile.armies >= 1 &&
      from_tile.owner == current_player_id &&
      defender_id != current_player_id &&
      to_id in from_tile.neighbors
    ) do
      outcome = outcome || Enum.random(@battle_outcomes)
      case outcome do
        :attacker ->
          if state.tiles[to_id].armies <= 1 do
            state
            |> update_tile(from_id, :armies, &(&1 - 1))
            |> put_tile(to_id, :owner, current_player_id)
            |> put_tile(to_id, :armies, 1)
            |> deactivate_player_if_defeated(defender_id)
            |> maybe_declare_winner()
          else
            state
            |> update_tile(to_id, :armies, &(&1 - 1))
          end
        :defender ->
          state
          |> update_tile(from_id, :armies, &(&1 - 1))
      end
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
    Enum.reduce(Map.keys(state.players), state, fn(player_id, state) ->
      not_really_random_tile = player_id * 6
      update_in(state, [:tiles, not_really_random_tile], fn(tile) ->
        struct(tile, %{owner: player_id})
      end)
    end)
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
      |> put_player(player_id, :unplaced_armies, 0)
    end
  end

  defp maybe_declare_winner(state) do
    active_player_ids =
      state.players
      |> Enum.filter(fn({_id, player}) -> player.active end)
      |> Enum.into(%{})
      |> Map.keys

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
end
