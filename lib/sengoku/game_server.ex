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
         1 => %{ owner: nil, armies: 0, neighbors: [2]},
         2 => %{ owner: nil, armies: 0, neighbors: [1, 3]},
         3 => %{ owner: nil, armies: 0, neighbors: [2, 4, 6]},
         4 => %{ owner: nil, armies: 0, neighbors: [3, 5]},
         5 => %{ owner: nil, armies: 0, neighbors: [4, 6]},
         6 => %{ owner: nil, armies: 0, neighbors: [3, 5, 7, 10]},
         7 => %{ owner: nil, armies: 0, neighbors: [6, 8, 9, 10]},
         8 => %{ owner: nil, armies: 0, neighbors: [7, 9]},
         9 => %{ owner: nil, armies: 0, neighbors: [7, 8, 12, 13, 14]},
        10 => %{ owner: nil, armies: 0, neighbors: [6, 7, 11, 12]},
        11 => %{ owner: nil, armies: 0, neighbors: [10, 12]},
        12 => %{ owner: nil, armies: 0, neighbors: [9, 10, 11, 14, 15, 16]},
        13 => %{ owner: nil, armies: 0, neighbors: [9, 14]},
        14 => %{ owner: nil, armies: 0, neighbors: [9, 12, 13, 15, 16, 17, 18, 19]},
        15 => %{ owner: nil, armies: 0, neighbors: [12, 14, 16]},
        16 => %{ owner: nil, armies: 0, neighbors: [12, 14, 15, 17]},
        17 => %{ owner: nil, armies: 0, neighbors: [14, 16, 19, 20]},
        18 => %{ owner: nil, armies: 0, neighbors: [14, 19]},
        19 => %{ owner: nil, armies: 0, neighbors: [14, 17, 18, 20, 21]},
        20 => %{ owner: nil, armies: 0, neighbors: [17, 19, 21, 24, 25, 28]},
        21 => %{ owner: nil, armies: 0, neighbors: [19, 20, 22, 23, 24]},
        22 => %{ owner: nil, armies: 0, neighbors: [21]},
        23 => %{ owner: nil, armies: 0, neighbors: [21, 24]},
        24 => %{ owner: nil, armies: 0, neighbors: [20, 21, 23, 25, 26]},
        25 => %{ owner: nil, armies: 0, neighbors: [20, 24, 26, 28]},
        26 => %{ owner: nil, armies: 0, neighbors: [24, 25, 27, 28]},
        27 => %{ owner: nil, armies: 0, neighbors: [26, 28]},
        28 => %{ owner: nil, armies: 0, neighbors: [20, 25, 26, 27, 29]},
        29 => %{ owner: nil, armies: 0, neighbors: [28]}
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
