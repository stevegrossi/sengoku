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

  def game_open?(game_id) do
    GenServer.call(via_tuple(game_id), :game_open?)
  end

  def authenticate_player(game_id, token) do
    GenServer.call(via_tuple(game_id), {:authenticate_player, token})
  end

  def start_game(game_id) do
    GenServer.call(via_tuple(game_id), :start_game)
  end

  def end_turn(game_id) do
    GenServer.call(via_tuple(game_id), :end_turn)
  end

  def place_army(game_id, tile_id) do
    GenServer.call(via_tuple(game_id), {:place_army, tile_id})
  end

  def attack(game_id, from_id, to_id) do
    GenServer.call(via_tuple(game_id), {:attack, from_id, to_id})
  end

  def state(game_id) do
    GenServer.call(via_tuple(game_id), :state)
  end

  # Server

  def handle_call(:game_open?, _from, state) do
    reply = Game.game_open?(state)
    {:reply, reply, state}
  end

  def handle_call({:authenticate_player, token}, _from, state) do
    case Game.authenticate_player(state, token) do
      {:ok, {player_id, token}, new_state} ->
        {:reply, {:ok, player_id, token}, new_state}
      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end

  def handle_call(:start_game, _from, state) do
    new_state = Game.start_game(state)
    {:reply, new_state, new_state}
  end

  def handle_call(:end_turn, _from, state) do
    new_state = Game.end_turn(state)
    {:reply, new_state, new_state}
  end

  def handle_call({:place_army, tile_id}, _from, state) do
    new_state = Game.place_army(state, tile_id)
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
