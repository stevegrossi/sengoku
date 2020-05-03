defmodule SengokuWeb.GameLive do
  use SengokuWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    #
    {:ok, assign(socket, player_ids: [])}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <h2>Players:</h2>
    <ul>
      <%= for player_id <- @player_ids do %>
        <li><%= player_id %></li>
      <% end %>
    </ul>
    """
  end

  # @impl true
  # def handle_event("suggest", %{"q" => query}, socket) do
  #   {:noreply, assign(socket, results: search(query), query: query)}
  # end
end
