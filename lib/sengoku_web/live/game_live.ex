defmodule SengokuWeb.GameLive do
  use SengokuWeb, :live_view

  require Logger

  alias Sengoku.GameServer
  alias SengokuWeb.MoveUnitsForm

  @impl Phoenix.LiveView
  def mount(%{"game_id" => game_id}, %{"player_id" => player_id}, socket) do
    if GameServer.alive?(game_id) do
      game_state = GameServer.get_state(game_id)

      if connected?(socket) do
        Phoenix.PubSub.subscribe(Sengoku.PubSub, "game:" <> game_id)
      end

      {:ok,
       assign(socket,
         game_id: game_id,
         player_id: player_id,
         player_number: game_state.tokens[player_id],
         game_state: game_state
       )}
    else
      {:ok,
       socket
       |> put_flash(:error, "Game not found. Start a new one?")
       |> redirect(to: Routes.game_path(SengokuWeb.Endpoint, :new))}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~L"""
    <div class="Game">
      <%= if @game_state.winner_id do %>
        <div class="Modal GameOver">
          <div>
            <p class="jumbo"><%= @game_state.players[@game_state.winner_id].name %> wins!</p>
            <p><a href="<%= Routes.game_path(@socket, :new) %>" class="Button Button--primary">Start a New Game</a></p>
          </div>
        </div>
      <% end %>

      <div class="Display">
        <h1 class="Logo">
          <a href="/">
            <img src="<%= Routes.static_path(@socket, "/images/sengoku.svg") %>" alt="Sengoku" />
          </a>
        </h1>

        <ol class="Players">
          <%= for {player_number, player} <- @game_state.players do %>
            <li class="Player <%= "player-bg-#{player_number}" %> <%= if not player.active, do: "Player--inactive" %> <%= if @game_state.current_player_number == player_number, do: "Player--current" %>">
              <b>
                <%= player.name %>
                <%= if player.ai do %>
                  <small class="Player-type">AI</small>
                <% end %>
              </b>
              <%= if player.unplaced_units > 0 do %>
                <span class="Player-unplacedUnits">
                  <%= player.unplaced_units %>
                  <svg class="Icon" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg" version="1.1" >
                    <use href="#icon-unit" />
                  </svg>
                </span>
              <% end %>
            </li>
          <% end %>
        </ol>

        <%= if @game_state.turn == 0 && not Map.has_key?(@game_state.tokens, @player_id) do %>
          <form phx-submit="join">
            <label for="player_name" class="visually-hidden">Your Name:</label>
            <div class="ComboInput">
              <input id="player_name" class="ComboInput-input" type="text" name="player_name" placeholder="Your Name" required autofocus />
              <input type="submit" class="Button ComboInput-button" value="Join" />
            </div>
          </form>
        <% end %>

        <%= if @game_state.turn == 0 && @player_number do %>
          <button class="Button" phx-click="start">Start Game</button>
        <% end %>

        <%= if @game_state.turn > 0 && !@game_state.winner_id && @game_state.current_player_number == @player_number do %>
          <button class="Button" phx-click="end_turn">End Turn</button>
        <% end %>

        <%= if @game_state.regions != %{} do %>
          <h2 class="text-center">Region Bonuses</h2>
          <ol class="Regions">
            <%= for {region_id, region} <- @game_state.regions do %>
              <li class="
                Region
                region-<%= region_id %>
                <%= case owner_of_region(region, @game_state.tiles) do %>
                  <%= {:ok, owner_id} -> %>
                    <%= "region-ownedby-#{owner_id}" %>
                  <% _ -> %>
                <% end %>
              ">
                <svg viewBox="0 0 200 200" version="1.1">
                  <use href="#hexagon" />
                </svg>
                <span class="Region-value"><%= region.value %></span>
              </li>
            <% end %>
          </ol>
        <% end %>

        <p>
          <%= if @game_state.turn == 0 do %>
            <%= if @player_number do %>
              You’re in! Share the URL with a friend to invite them, or start the game when ready.
            <% else %>
              You are currently spectating. Join the game or wait and watch.
            <% end %>
          <% else %>
            <%= if @game_state.current_player_number == @player_number && !@game_state.winner_id do %>
              <%= cond do %>
                <% @game_state.players[@game_state.current_player_number].unplaced_units > 0 -> %>
                  <%= "You have #{@game_state.players[@game_state.current_player_number].unplaced_units} units to place. Click on one of your territories to place a unit." %>
                <% is_nil(@game_state.selected_tile_id) -> %>
                  Select one of your territories to attack or move from, or end your turn.
                <% @game_state.tiles[@game_state.selected_tile_id].units == 1 -> %>
                  You must have more than 1 unit in a territory to move or attack.
                <% true -> %>
                  Select an adjacent territory to attack or move into.
              <% end %>
            <% end %>
          <% end %>
        </p>
      </div>

      <div
        class="Board"
        <%= if @game_state.selected_tile_id, do: "phx-click=unselect_tile" %>
      >
        <%= if @game_state.pending_move && is_nil(@game_state.winner_id) && @game_state.current_player_number == @player_number do %>
          <%= live_component(@socket, MoveUnitsForm, id: "move_form", pending_move: @game_state.pending_move) %>
        <% end %>
        <ul class="Tiles">
          <%= for {id, tile} <- @game_state.tiles do %>
            <li
              class="
                Tile
                <%= "region-#{elem(Enum.find(@game_state.regions, fn({_id, region}) -> id in region.tile_ids end), 0)}" %>
                <%= if id == @game_state.selected_tile_id, do: "Tile--selected" %>
              "
              id="tile_<%= id %>"
              <%= if @player_number && @game_state.current_player_number && @player_number == @game_state.current_player_number do %>
                <%= cond do %>
                  <% @game_state.players[@game_state.current_player_number].unplaced_units > 0 && @game_state.tiles[id].owner == @game_state.current_player_number -> %>
                    phx-click="place_unit"
                  <% is_nil(@game_state.selected_tile_id) && @game_state.tiles[id].units > 1 && @game_state.tiles[id].owner == @game_state.current_player_number -> %>
                    phx-click="select_tile"
                  <% @game_state.selected_tile_id && id in @game_state.tiles[@game_state.selected_tile_id].neighbors -> %>
                    <%= if @game_state.tiles[id].owner == @game_state.current_player_number do %>
                      phx-click="start_move"
                    <% else %>
                      phx-click="attack"
                    <% end %>
                  <% true -> %>
                <% end %>
              <% end %>
              phx-value-tile_id="<%= id %>"
            >
              <svg viewBox="0 0 200 200" version="1.1">
                <use href="#hexagon" />
              </svg>
              <span class="TileCenter <%= "player-bg-#{tile.owner}" %>"><%= tile.units %></span>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_info({:game_updated, new_state}, socket) do
    {:noreply, assign(socket, game_state: new_state)}
  end

  @impl Phoenix.LiveView
  def handle_event("join", %{"player_name" => player_name}, socket) do
    case GameServer.authenticate_player(
           socket.assigns.game_id,
           socket.assigns.player_id,
           player_name
         ) do
      {:ok, player_number, _token} ->
        {:noreply, assign(socket, player_number: player_number)}

      {:error, reason} ->
        Logger.info("Failed to join game: #{reason}")
        {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("start", _params, socket) do
    %{game_id: game_id, player_number: player_number} = socket.assigns
    GameServer.action(game_id, player_number, %{type: "start_game"})

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("place_unit", %{"tile_id" => tile_id_string}, socket) do
    {tile_id, _} = Integer.parse(tile_id_string)
    %{game_id: game_id, player_number: player_number} = socket.assigns
    GameServer.action(game_id, player_number, %{type: "place_unit", tile_id: tile_id})

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("end_turn", _params, socket) do
    %{game_id: game_id, player_number: player_number} = socket.assigns
    GameServer.action(game_id, player_number, %{type: "end_turn"})

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("select_tile", %{"tile_id" => tile_id_string}, socket) do
    {tile_id, _} = Integer.parse(tile_id_string)
    %{game_id: game_id, player_number: player_number} = socket.assigns
    GameServer.action(game_id, player_number, %{type: "select_tile", tile_id: tile_id})

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("unselect_tile", _params, socket) do
    %{game_id: game_id, player_number: player_number} = socket.assigns
    GameServer.action(game_id, player_number, %{type: "unselect_tile"})

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("attack", %{"tile_id" => tile_id_string}, socket) do
    {tile_id, _} = Integer.parse(tile_id_string)

    %{game_id: game_id, player_number: player_number, game_state: %{selected_tile_id: selected_tile_id}} =
      socket.assigns

    GameServer.action(game_id, player_number, %{
      type: "attack",
      from_id: selected_tile_id,
      to_id: tile_id
    })

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("start_move", %{"tile_id" => tile_id_string}, socket) do
    {to_tile_id, _} = Integer.parse(tile_id_string)

    %{game_id: game_id, player_number: player_number, game_state: %{selected_tile_id: selected_tile_id}} =
      socket.assigns

    GameServer.action(game_id, player_number, %{
      type: "start_move",
      from_id: selected_tile_id,
      to_id: to_tile_id
    })

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("move", %{"count" => count_string}, socket) do
    {count, _} = Integer.parse(count_string)

    %{game_id: game_id, player_number: player_number, game_state: %{pending_move: pending_move}} =
      socket.assigns

    GameServer.action(game_id, player_number, %{
      type: "move",
      from_id: pending_move.from_id,
      to_id: pending_move.to_id,
      count: count
    })

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel_move", _params, socket) do
    %{game_id: game_id, player_number: player_number} = socket.assigns
    GameServer.action(game_id, player_number, %{type: "cancel_move"})

    {:noreply, socket}
  end

  defp owner_of_region(region, tiles) do
    region.tile_ids
    |> Enum.map(fn tile_id ->
      tiles[tile_id].owner
    end)
    |> Enum.uniq()
    |> case do
      [owner_id] -> {:ok, owner_id}
      _ -> nil
    end
  end
end
