defmodule Sengoku.GameServer do
  use GenServer

  @players %{
    1 => %{unplaced_armies: 0},
    2 => %{unplaced_armies: 0},
    3 => %{unplaced_armies: 0},
    4 => %{unplaced_armies: 0}
  }
  @min_additional_armies 3

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
      |> assign_territories()
      |> begin_turn()

    {:ok, state}
  end

  # API

  def end_turn(game_id) do
    GenServer.call(via_tuple(game_id), :end_turn)
  end

  def place_armies(game_id, count, territory_id) do
    GenServer.call(via_tuple(game_id), {:place_armies, count, territory_id})
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

  def handle_call({:place_armies, count, territory_id}, _from, %{current_player_id: current_player_id} = state) do
    current_player = state.players[current_player_id]
    new_state =
      if count <= current_player.unplaced_armies do
        territory = state.territories[territory_id]

        if territory.owner == current_player_id do
          state
          |> update_in([:players, current_player_id, :unplaced_armies], &(&1 - count))
          |> update_in([:territories, territory_id, :armies], &(&1 + count))
        else
          state
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

  defp assign_territories(state) do
    territory_ids = Map.keys(state.territories)
    Enum.reduce(Map.keys(@players), state, fn(player_id, state) ->
      put_in(state, [:territories, player_id * 6, :owner], player_id)
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
      territories: %{
         1 => %{ owner: nil, armies: 0},
         2 => %{ owner: nil, armies: 0},
         3 => %{ owner: nil, armies: 0},
         4 => %{ owner: nil, armies: 0},
         5 => %{ owner: nil, armies: 0},
         6 => %{ owner: nil, armies: 0},
         7 => %{ owner: nil, armies: 0},
         8 => %{ owner: nil, armies: 0},
         9 => %{ owner: nil, armies: 0},
        10 => %{ owner: nil, armies: 0},
        11 => %{ owner: nil, armies: 0},
        12 => %{ owner: nil, armies: 0},
        13 => %{ owner: nil, armies: 0},
        14 => %{ owner: nil, armies: 0},
        15 => %{ owner: nil, armies: 0},
        16 => %{ owner: nil, armies: 0},
        17 => %{ owner: nil, armies: 0},
        18 => %{ owner: nil, armies: 0},
        19 => %{ owner: nil, armies: 0},
        20 => %{ owner: nil, armies: 0},
        21 => %{ owner: nil, armies: 0},
        22 => %{ owner: nil, armies: 0},
        23 => %{ owner: nil, armies: 0},
        24 => %{ owner: nil, armies: 0},
        25 => %{ owner: nil, armies: 0},
        26 => %{ owner: nil, armies: 0},
        27 => %{ owner: nil, armies: 0},
        28 => %{ owner: nil, armies: 0},
        29 => %{ owner: nil, armies: 0}
      }
    }
  end

  defp random_token(length) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
