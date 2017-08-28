defmodule Sengoku.GameServer do
  use GenServer

  @players [1, 2, 3, 4]

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
    {:ok, %{
      game_id: game_id,
      turn: 1,
      current_player: List.first(@players),
      players: @players
    }}
  end

  # API

  def end_turn(game_id) do
    GenServer.call(via_tuple(game_id), :end_turn)
  end

  def state(game_id) do
    GenServer.call(via_tuple(game_id), :state)
  end

  # Server

  def handle_call(:end_turn, _from, %{current_player: current_player} = state) do
    next_player_in_list = current_player + 1
    new_state =
      case Enum.member?(@players, next_player_in_list) do
        true ->
          state
            |> Map.put(:current_player, next_player_in_list)
        false ->
          state
          |> Map.update!(:turn, &(&1 + 1))
          |> Map.put(:current_player, List.first(@players))
      end
    {:reply, new_state, new_state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  defp via_tuple(game_id) do
    {:via, Registry, {:game_server_registry, game_id}}
  end

  defp random_token(length) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
