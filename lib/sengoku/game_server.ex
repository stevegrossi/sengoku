defmodule Sengoku.GameServer do
  use GenServer

  alias Sengoku.Game

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
    {:ok, Game.initial_state(mode)}
  end

  # API

  def authenticate_player(game_id, token) do
    GenServer.call(via_tuple(game_id), {:authenticate_player, token})
  end

  def action(game_id, player_id, %{type: _type} = action) do
    GenServer.call(via_tuple(game_id), {:action, player_id, action})
  end

  def state(game_id) do # TODO: rename: get_state
    GenServer.call(via_tuple(game_id), :state)
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

  def handle_call({:action, player_id, %{type: type} = action}, _from, state) do
    new_state =
      case type do
        "start_game" ->
          Game.start_game(state)
        "end_turn" ->
          if state.current_player_id == player_id do
            Game.end_turn(state)
          else
            state
          end
        "place_army" ->
          if state.current_player_id == player_id do
            Game.place_army(state, action.tile_id)
          else
            state
          end
        "attack" ->
          if state.current_player_id == player_id do
            Game.attack(state, action.from_id, action.to_id)
          else
            state
          end
        _ ->
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

  defp random_token(length) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
