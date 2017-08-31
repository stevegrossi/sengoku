defmodule SengokuWeb.GameChannel do
  use SengokuWeb, :channel

  alias Sengoku.GameServer

  def join("games:" <> game_id, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :game_id, game_id)
      send self(), :after_join
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("action", action, socket) do
    game_id = socket.assigns[:game_id]
    new_state = command!(game_id, action)
    if new_state do
      broadcast socket, "update", new_state
    end
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "update", GameServer.state(socket.assigns[:game_id])
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp command!(game_id, %{"type" => "end_turn"} = action) do
    GameServer.end_turn(game_id)
  end
  defp command!(game_id, %{"type" => "place_armies",
                           "count" => count,
                           "territory" => territory}) do

    GameServer.place_armies(game_id, count, territory)
  end
  defp command!(game_id, %{"type" => "attack",
                           "from" => from_id,
                           "to" => to_id}) do

    GameServer.attack(game_id, from_id, to_id)
  end
  defp command!(game_id, _), do: nil
end
