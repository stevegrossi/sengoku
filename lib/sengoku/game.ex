defmodule Sengoku.Game do
  alias Sengoku.{Tile, Player}

  @min_additional_armies 3
  @battle_outcomes ~w(attacker defender)a

  def initial_state do
    new_state()
    |> assign_tiles
    |> begin_turn
  end

  def begin_turn(%{current_player_id: current_player_id} = state) do
    state
    |> update_player(current_player_id, :unplaced_armies, &(&1 + @min_additional_armies))
  end

  def end_turn(%{current_player_id: current_player_id} = state) do
    next_player_id = current_player_id + 1
    case Map.has_key?(Player.initial_state, next_player_id) do
      true ->
        state
          |> Map.put(:current_player_id, next_player_id)
      false ->
        state
        |> Map.update!(:turn, &(&1 + 1))
        |> Map.put(:current_player_id, Player.first_id)
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

    if (
      from_tile.armies >= 1 &&
      from_tile.owner == current_player_id &&
      to_tile.owner != current_player_id &&
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

  defp new_state do
    %{
      turn: 1,
      current_player_id: Player.first_id,
      players: Player.initial_state,
      tiles: Tile.initial_state
    }
  end

  defp assign_tiles(state) do
    Enum.reduce(Player.ids, state, fn(player_id, state) ->
      not_really_random_tile = player_id * 6
      update_in(state, [:tiles, not_really_random_tile], fn(tile) ->
        struct(tile, %{owner: player_id})
      end)
    end)
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

  defp update_player(state, player_id, key, func) do
    update_in(state, [:players, player_id], fn(%Player{} = player) ->
      Map.update!(player, key, func)
    end)
  end
end
