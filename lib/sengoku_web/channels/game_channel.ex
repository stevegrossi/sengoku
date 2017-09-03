defmodule SengokuWeb.GameChannel do
  use SengokuWeb, :channel

  alias Sengoku.GameServer

  def join("games:" <> game_id, %{"token" => token}, socket) do
    case GameServer.authenticate_player(game_id, token) do
      {:ok, player_id, token} ->
        socket =
          socket
          |> assign(:game_id, game_id)
          |> assign(:player_id, player_id)
        send self(), :after_join
        {:ok, %{token: token}, socket}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

  def handle_in("action", action, socket) do
    game_id = socket.assigns[:game_id]
    player_id = socket.assigns[:player_id]
    action = atomize_keys(action)
    new_state = GameServer.action(game_id, player_id, action)

    broadcast socket, "update", new_state
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    state = GameServer.state(socket.assigns[:game_id])
    broadcast socket, "update", state
    {:noreply, socket}
  end

  defp atomize_keys(%{} = map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end
end
