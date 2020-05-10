defmodule SengokuWeb.GameLive do
  use SengokuWeb, :live_view

  alias Sengoku.GameServer

  @impl true
  def mount(params, session, socket) do
    player_id = session["anonymous_user_id"]
    game_id = params["game_id"]
    game_state = GameServer.get_state(game_id)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Sengoku.PubSub, "game:" <> game_id)
    end

    {:ok, assign(socket, game_id: game_id, player_id: player_id, game_state: game_state)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <h2>Player</h2>
    <p><%= @player_id %></p>
    <button phx-click="join">Join Game</button>
    <h2>Game State</h2>
    <p><code><%= inspect(@game_state.players) %></code></p>
    """
  end

  @impl true
  def handle_info({:game_updated, new_state}, socket) do
    {:noreply, assign(socket, game_state: new_state)}
  end

  @impl true
  def handle_event("join", _params, socket) do
    GameServer.authenticate_player(
      socket.assigns.game_id,
      socket.assigns.player_id,
      socket.assigns.player_id
    )

    {:noreply, socket}
  end
end
