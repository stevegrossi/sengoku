defmodule Sengoku.GameServer do
  use GenServer

  alias Sengoku.Tile

  @players %{
    1 => %{unplaced_armies: 0},
    2 => %{unplaced_armies: 0},
    3 => %{unplaced_armies: 0},
    4 => %{unplaced_armies: 0}
  }
  @min_additional_armies 3
  @outcomes ~w(attacker defender)a

  def new do
    game_id = random_token(7)
    start_link(game_id)
    {:ok, game_id}
  end

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id)
  end

  def init(game_id) do
    case Registry.register(:game_server_registry, game_id, :ok) do
      {:ok, _pid} -> {:ok, game_id}
      {:error, reason} -> {:error, reason}
    end
    state =
      game_id
      |> get_initial_state()
      |> assign_tiles()
      |> begin_turn()

    {:ok, state}
  end

  # API

  def end_turn(game_id) do
    GenServer.call(via_tuple(game_id), :end_turn)
  end

  def place_armies(game_id, count, tile_id) do
    GenServer.call(via_tuple(game_id), {:place_armies, count, tile_id})
  end

  def attack(game_id, from_id, to_id) do
    GenServer.call(via_tuple(game_id), {:attack, from_id, to_id})
  end

  def state(game_id) do
    GenServer.call(via_tuple(game_id), :state)
  end

  # Server

  def handle_call(:end_turn, _from, %{current_player_id: current_player_id} = state) do
    next_player_id = current_player_id + 1
    new_state =
      case Map.has_key?(@players, next_player_id) do
        true ->
          state
            |> Map.put(:current_player_id, next_player_id)
        false ->
          state
          |> Map.update!(:turn, &(&1 + 1))
          |> Map.put(:current_player_id, List.first(Map.keys(@players)))
      end
      |> begin_turn()

    {:reply, new_state, new_state}
  end

  def handle_call({:place_armies, count, tile_id}, _from, %{current_player_id: current_player_id} = state) do
    current_player = state.players[current_player_id]
    new_state =
      if count <= current_player.unplaced_armies do
        tile = state.tiles[tile_id]

        if tile.owner == current_player_id do
          state
          |> update_in([:players, current_player_id, :unplaced_armies], &(&1 - count))
          |> update_in([:tiles, tile_id], fn(tile) ->
               struct(tile, %{armies: tile.armies + 1})
             end)
        else
          state
        end
      else
        state
      end
    {:reply, new_state, new_state}
  end

  def handle_call({:attack, from_id, to_id}, _from, %{current_player_id: current_player_id} = state) do
    current_player = state.players[current_player_id]
    from_tile = state.tiles[from_id]
    to_tile = state.tiles[to_id]

    new_state =
      if (
        from_tile.armies >= 1 &&
        from_tile.owner == current_player_id &&
        to_tile.owner != current_player_id &&
        to_id in from_tile.neighbors
      ) do
        case Enum.random(@outcomes) do
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

    {:reply, new_state, new_state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  defp via_tuple(game_id) do
    {:via, Registry, {:game_server_registry, game_id}}
  end

  defp assign_tiles(state) do
    tile_ids = Map.keys(state.tiles)
    Enum.reduce(Map.keys(@players), state, fn(player_id, state) ->
      not_really_random_tile = player_id * 6
      update_in(state, [:tiles, not_really_random_tile], fn(tile) ->
        struct(tile, %{owner: player_id})
      end)
    end)
  end

  defp begin_turn(%{current_player_id: current_player_id} = state) do
    state
    |> update_in([:players, current_player_id, :unplaced_armies], &(&1 + @min_additional_armies))
  end

  defp get_initial_state(game_id) do
    %{
      game_id: game_id,
      turn: 1,
      current_player_id: List.first(Map.keys(@players)),
      players: @players,
      tiles: Tile.initial_state
    }
  end

  defp random_token(length) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
