defmodule SengokuWeb.GameChannel do
  @moduledoc """
  The interface between the browser and the GameServer.
  """

  use SengokuWeb, :channel

  alias Sengoku.GameServer

  def join("games:" <> game_id, %{"token" => token}, socket) do
    socket = assign(socket, :game_id, game_id)
    send self(), :after_join
    {:ok, socket}
  end

  def handle_in("join_as_player", %{"token" => token, "name" => name}, socket) do
    game_id = socket.assigns[:game_id]
    case GameServer.authenticate_player(game_id, token, name) do
      {:ok, player_id, token} ->
        send self(), :after_join
        {:reply, {:ok, %{token: token, player_id: player_id}}, assign(socket, :player_id, player_id)}
      {:error, reason} ->
        {:reply, {:ok, %{error: reason}}, socket}
    end
  end
  def handle_in("action", action, socket) do
    game_id = socket.assigns[:game_id]
    player_id = socket.assigns[:player_id]
    action = atomize_keys(action)
    GameServer.action(game_id, player_id, action)
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    state = GameServer.get_state(socket.assigns[:game_id])
    broadcast socket, "update", state
    {:noreply, socket}
  end

  defp atomize_keys(%{} = map) do
    for {key, val} <- map, into: %{}, do: {String.to_existing_atom(key), val}
  end
end
