defmodule Sengoku.GameServer do
  @moduledoc """
  A GenServer responsible for maintaining the entire state of a single game,
  including dispatching players’ actions to change that state.
  """

  use GenServer

  require Logger

  alias Sengoku.{Authentication, Game, Token, AI}
  alias SengokuWeb.Endpoint

  @ai_think_time 250 # ms

  def new(%{} = options) do
    game_id = Token.new(8)
    start_link(game_id, options)
    {:ok, game_id}
  end

  def start_link(game_id, options) do
    GenServer.start_link(__MODULE__, {game_id, options})
  end

  def init({game_id, options}) do
    case Registry.register(:game_server_registry, game_id, :ok) do
      {:ok, _pid} -> {:ok, game_id}
      {:error, reason} -> {:error, reason}
    end
    {:ok, Game.initialize_state(game_id, options)}
  end

  # API

  def authenticate_player(game_id, token, name \\ nil) do
    GenServer.call(via_tuple(game_id), {:authenticate_player, token, name})
  end

  def action(game_id, player_id, %{type: _type} = action) do
    GenServer.cast(via_tuple(game_id), {:action, player_id, action})
  end

  def get_state(game_id) do
    GenServer.call(via_tuple(game_id), :get_state)
  end

  # Server

  def handle_call({:authenticate_player, token, name}, _from, state) do
    case Authentication.authenticate_player(state, token, name) do
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
  def handle_cast({:action, player_id, %{} = action}, state) do
    if player_id == state.current_player_id do
      new_state = Game.handle_action(state, action)
      state_updated(new_state)
      {:noreply, new_state}
    else
      Logger.info("It’s not your turn, player " <> Integer.to_string(player_id))
      {:noreply, state}
    end
  end

  def handle_info(:take_ai_move_if_necessary, state) do
    if Game.current_player(state).ai && !state.winner_id do
      Process.sleep(@ai_think_time)
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
