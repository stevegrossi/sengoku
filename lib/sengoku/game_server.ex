defmodule Sengoku.GameServer do
  @moduledoc """
  A GenServer responsible for maintaining the entire state of a single game,
  including dispatching players’ actions to change that state.
  """

  use GenServer

  require Logger

  alias Sengoku.{Authentication, Game, Token, AI}

  @default_ai_wait_time_ms 100

  def new(%{} = options, arena \\ false) do
    game_id = Token.new(8)
    start_link(game_id, options, arena)
    {:ok, game_id}
  end

  def start_link(game_id, options, arena) do
    GenServer.start_link(__MODULE__, {game_id, options, arena})
  end

  def init({game_id, options, arena}) do
    case Registry.register(:game_server_registry, game_id, :ok) do
      {:ok, _pid} -> {:ok, game_id}
      {:error, reason} -> {:error, reason}
    end

    {:ok, Map.put(Game.initialize_state(game_id, options), :arena, arena)}
  end

  # API

  def alive?(game_id) do
    Registry.lookup(:game_server_registry, game_id) != []
  end

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
        state_updated(new_state)
        {:reply, {:ok, player_id, token}, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:action, _player_id, %{type: "start_game"}}, state) do
    new_state = Game.start_game(state)
    state_updated(new_state)
    {:noreply, new_state}
  end

  def handle_cast({:action, player_id, %{} = action}, state) do
    if player_id == state.current_player_number do
      new_state = Game.handle_action(state, action)
      state_updated(new_state)
      {:noreply, new_state}
    else
      if is_nil(player_id) do
        Logger.info("You’re not even playing.")
      else
        Logger.info("It’s not your turn, player " <> Integer.to_string(player_id))
      end

      {:noreply, state}
    end
  end

  def handle_info(:take_ai_move_if_necessary, state) do
    if Game.current_player(state) && Game.current_player(state).ai && !state.winning_player do
      unless state.arena, do: Process.sleep(ai_wait_time())
      action = Game.current_player(state).ai.take_action(state)
      action(state.id, state.current_player_number, action)
    end

    {:noreply, state}
  end

  defp ai_wait_time do
    case System.get_env("AI_WAIT_TIME_MS") do
      nil -> @default_ai_wait_time_ms
      string -> String.to_integer(string)
    end
  end

  defp state_updated(state) do
    send(self(), :take_ai_move_if_necessary)
    unless state.arena do
      Phoenix.PubSub.broadcast(Sengoku.PubSub, "game:" <> state.id, {:game_updated, state})
    end
  end

  defp via_tuple(game_id) do
    {:via, Registry, {:game_server_registry, game_id}}
  end
end
