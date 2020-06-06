defmodule SengokuWeb.BoardBuilderLive do
  use SengokuWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, tiles: build_tiles() )}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~L"""
    <div class="Game">
      <div class="Display">
        <h1 class="Logo">
          <a href="/">
            <img src="<%= Routes.static_path(@socket, "/images/sengoku.svg") %>" alt="Sengoku" />
          </a>
        </h1>

        <h2>Board Builder</h2>
        <p>Instructions...</p>
      </div>

      <div class="Board">
        <ul class="Tiles">
          <%= for {tile_id, selected} <- @tiles do %>
            <li
              class="
                Tile
                <%= unless selected, do: "opacity-25" %>
              "
              id="tile_<%= tile_id %>"
              phx-click="toggle"
              phx-value-tile_id="<%= tile_id %>"
            >
              <svg viewBox="0 0 200 200" version="1.1">
                <use href="#hexagon" />
              </svg>
              <span class="TileCenter"><%= tile_id %></span>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("toggle", %{"tile_id" => tile_id_string}, socket) do
    tile_id = String.to_integer(tile_id_string)
    new_tiles =
      socket.assigns.tiles
      |> Map.update!(tile_id, &(!&1))

    {:noreply, assign(socket, tiles: new_tiles)}
  end

  defp build_tiles do
    1..85
    |> Enum.to_list()
    |> Enum.map(fn(id) ->
         {id, false}
       end)
    |> Enum.into(%{})
  end
end
