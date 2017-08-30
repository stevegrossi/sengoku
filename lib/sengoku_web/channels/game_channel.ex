defmodule SengokuWeb.GameChannel do
  use SengokuWeb, :channel

  def join("games:" <> game_id, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :game_id, game_id)
      send self(), :after_join
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end

  def handle_in("end_turn", _payload, socket) do
    state = Sengoku.GameServer.end_turn(socket.assigns[:game_id])
    broadcast socket, "update", state
    {:noreply, socket}
  end

  def handle_in("place_armies", %{"count" => count, "territory" => territory_id}, socket) do
    state = Sengoku.GameServer.place_armies(socket.assigns[:game_id], count, territory_id)
    broadcast socket, "update", state
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "update", Sengoku.GameServer.state(socket.assigns[:game_id])
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
