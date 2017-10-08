defmodule Sengoku.GameServer do
  use GenServer

  require Logger

  alias Sengoku.{Game, Token, AI}
  alias SengokuWeb.Endpoint

  def new do
    game_id = Token.new(8)
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
    {:ok, Game.initialize_state(game_id)}
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

  def handle_call(:get_state, _from, state) do
    {:reply, public_state(state), state}
  end

  def handle_cast({:action, _player_id, %{type: "start_game"}}, state) do
    new_state = Game.start_game(state)
    state_updated(new_state)
    {:noreply, new_state}
  end
  def handle_cast({:action, player_id, %{type: "end_turn"}}, %{current_player_id: player_id} = state) do
    new_state = Game.end_turn(state)
    state_updated(new_state)
    {:noreply, new_state}
  end
  def handle_cast({:action, player_id, %{type: "place_unit", tile_id: tile_id}}, %{current_player_id: player_id} = state) do
    new_state = Game.place_unit(state, tile_id)
    state_updated(new_state)
    {:noreply, new_state}
  end
  def handle_cast({:action, player_id, %{type: "attack", from_id: from_id, to_id: to_id}}, %{current_player_id: player_id} = state) do
    new_state = Game.attack(state, from_id, to_id)
    state_updated(new_state)
    {:noreply, new_state}
  end
  def handle_cast({:action, player_id, %{type: "move", from_id: from_id, to_id: to_id, count: count}}, %{current_player_id: player_id} = state) do
    new_state = Game.move(state, from_id, to_id, count)
    state_updated(new_state)
    {:noreply, new_state}
  end
  def handle_cast({:action, player_id, action}, state) do
    Logger.info("Unrecognized action `#{inspect(action)}` by player `#{player_id}`")
    {:noreply, state}
  end

  def handle_info(:take_ai_move_if_necessary, state) do
    if Game.current_player(state).ai && !state.winner_id do
      Process.sleep(50)
      action = AI.Smart.take_action(state)
      action(state.id, state.current_player_id, action)
    end
    {:noreply, state}
  end

  defp state_updated(state) do
    send self(), :take_ai_move_if_necessary
    Endpoint.broadcast("games:" <> state.id, "update", state)
  end

  defp via_tuple(game_id) do
    {:via, Registry, {:game_server_registry, game_id}}
  end

  defp public_state(state) do
    Map.delete(state, :tokens)
  end
end
