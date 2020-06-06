defmodule SengokuWeb.BoardBuilderLive do
  use SengokuWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      tiles: build_tiles(),
      regions: 1..8,
      current_region: 1,
    )}
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
        <p>Select a region below, then click a tile at right to add it to the board in the selected region.</p>
        <ol class="Regions">
          <%= for region <- @regions do %>
            <li
              class="
                Region
                region-<%= region %>
                <%= if region == @current_region, do: "region-ownedby-1" %>
              "
              phx-click="select_region"
              phx-value-region_id="<%= region %>"
            >
              <svg viewBox="0 0 200 200" version="1.1">
                <use href="#hexagon" />
              </svg>
              <span class="Region-value"><%= region %></span>
            </li>
          <% end %>
        </ol>
      </div>

      <div class="Board">
        <ul class="Tiles">
          <%= for {tile_id, region} <- @tiles do %>
            <li
              class="
                Tile
                <%= if region, do: "region-#{region}", else: "opacity-25" %>
              "
              id="tile_<%= tile_id %>"
              phx-click="toggle_tile"
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
  def handle_event("toggle_tile", %{"tile_id" => tile_id_string}, socket) do
    tile_id = String.to_integer(tile_id_string)
    current_region = socket.assigns.current_region
    new_tiles =
      socket.assigns.tiles
      |> Map.update!(tile_id, fn(tile_region) ->
           case tile_region do
             ^current_region ->
               nil
             _ ->
               socket.assigns.current_region
           end
         end)

    {:noreply, assign(socket, tiles: new_tiles)}
  end

  @impl Phoenix.LiveView
  def handle_event("select_region", %{"region_id" => region_id_string}, socket) do
    region_id = String.to_integer(region_id_string)

    {:noreply, assign(socket, current_region: region_id)}
  end

  defp build_tiles do
    1..85
    |> Enum.to_list()
    |> Enum.map(fn(id) ->
         {id, nil}
       end)
    |> Enum.into(%{})
  end
end
