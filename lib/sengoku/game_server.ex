defmodule Sengoku.GameServer do
  use GenServer

  alias Sengoku.Game
  alias SengokuWeb.Endpoint

  def new(mode) do
    game_id = random_token(7)
    start_link(game_id, mode)
    {:ok, game_id}
  end

  def start_link(game_id, mode) do
    GenServer.start_link(__MODULE__, {game_id, mode})
  end

  def init({game_id, mode}) do
    case Registry.register(:game_server_registry, game_id, :ok) do
      {:ok, _pid} -> {:ok, game_id}
      {:error, reason} -> {:error, reason}
    end
    {:ok, Game.initial_state(game_id, mode)}
  end

  # API

  def authenticate_player(game_id, token) do
    GenServer.call(via_tuple(game_id), {:authenticate_player, token})
  end

  def action(game_id, player_id, %{type: _type} = action) do
    GenServer.cast(via_tuple(game_id), {:action, player_id, action})
  end

  def get_state(game_id) do
    GenServer.call(via_tuple(game_id), :get_state)
  end

  # Server

  def handle_call({:authenticate_player, token}, _from, state) do
    case Game.authenticate_player(state, token) do
      {:ok, {player_id, token}, new_state} ->
        {:reply, {:ok, player_id, token}, new_state}
      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end

  def handle_cast({:action, _player_id, %{type: "start_game"}}, state) do
    new_state = Game.start_game(state)
    broadcast_state(new_state)
    {:noreply, new_state}
  end

  # online
  def handle_cast({:action, player_id, %{type: "end_turn"}}, %{mode: :online, current_player_id: player_id} = state) do
    new_state = Game.end_turn(state)
    broadcast_state(new_state)
    {:noreply, new_state}
  end
  def handle_cast({:action, player_id, %{type: "place_unit", tile_id: tile_id}}, %{mode: :online, current_player_id: player_id} = state) do
    new_state = Game.place_unit(state, tile_id)
    broadcast_state(new_state)
    {:noreply, new_state}
  end
  def handle_cast({:action, player_id, %{type: "attack", from_id: from_id, to_id: to_id}}, %{mode: :online, current_player_id: player_id} = state) do
    new_state = Game.attack(state, from_id, to_id)
    broadcast_state(new_state)
    {:noreply, new_state}
  end
  def handle_cast({:action, player_id, %{type: "move", from_id: from_id, to_id: to_id, count: count}}, %{mode: :online, current_player_id: player_id} = state) do
    new_state = Game.move(state, from_id, to_id, count)
    broadcast_state(new_state)
    {:noreply, new_state}
  end

  # hot_seat
  def handle_cast({:action, _player_id, %{type: "end_turn"}}, %{mode: :hot_seat} = state) do
    new_state = Game.end_turn(state)
    broadcast_state(new_state)
    {:noreply, new_state}
  end
  def handle_cast({:action, _player_id, %{type: "place_unit", tile_id: tile_id}}, %{mode: :hot_seat} = state) do
    new_state = Game.place_unit(state, tile_id)
    broadcast_state(new_state)
    {:noreply, new_state}
  end
  def handle_cast({:action, _player_id, %{type: "attack", from_id: from_id, to_id: to_id}}, %{mode: :hot_seat} = state) do
    new_state = Game.attack(state, from_id, to_id)
    broadcast_state(new_state)
    {:noreply, new_state}
  end
  def handle_cast({:action, _player_id, %{type: "move", from_id: from_id, to_id: to_id, count: count}}, %{mode: :hot_seat} = state) do
    new_state = Game.move(state, from_id, to_id, count)
    broadcast_state(new_state)
    {:noreply, new_state}
  end

  # catch-all
  def handle_cast({:action, _player_id, _action}, state) do
    {:noreply, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, public_state(state), state}
  end

  defp broadcast_state(state) do
    Endpoint.broadcast("games:" <> state.id, "update", state)
  end

  defp via_tuple(game_id) do
    {:via, Registry, {:game_server_registry, game_id}}
  end

  defp public_state(state) do
    Map.delete(state, :tokens)
  end

  defp random_token(length) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
