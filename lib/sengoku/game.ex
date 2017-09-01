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
    |> update_in([:players, current_player_id], fn(player) ->
         struct(player, %{unplaced_armies: player.unplaced_armies + @min_additional_armies})
       end)
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
        |> update_in([:players, current_player_id], fn(player) ->
             struct(player, %{unplaced_armies: player.unplaced_armies - 1})
           end)
        |> update_in([:tiles, tile_id], fn(tile) ->
             struct(tile, %{armies: tile.armies + 1})
           end)
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
            |> update_in([:tiles, to_id], fn(tile) ->
                 struct(tile, %{owner: current_player_id, armies: 1})
               end)
            |> update_in([:tiles, from_id], fn(tile) ->
                 struct(tile, %{armies: tile.armies - 1})
               end)
          else
            state
            |> update_in([:tiles, to_id], fn(tile) ->
                 struct(tile, %{armies: tile.armies - 1})
               end)
          end
        :defender ->
          state
          |> update_in([:tiles, from_id], fn(tile) ->
               struct(tile, %{armies: tile.armies - 1})
             end)
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
end
