defmodule Sengoku.GameServer do
  use GenServer

  alias Sengoku.Game

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
    {:ok, Game.initial_state}
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

  def handle_call(:end_turn, _from, state) do
    new_state = Game.end_turn(state)
    {:reply, new_state, new_state}
  end

  def handle_call({:place_armies, count, tile_id}, _from, state) do
    new_state = Game.place_armies(state, count, tile_id)
    {:reply, new_state, new_state}
  end

  def handle_call({:attack, from_id, to_id}, _from, state) do
    new_state = Game.attack(state, from_id, to_id)
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
