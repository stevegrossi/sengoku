defmodule SengokuWeb.GameLiveTest do
  use SengokuWeb.ConnCase
  import Phoenix.LiveViewTest
  @endpoint SengokuWeb.Endpoint

  test "redirects when the GameServer is unavailable", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/"}}} = live(conn, "/games/no-game-here")
  end

  test "connected mount", %{conn: conn} do
    {:ok, game_id} = Sengoku.GameServer.new(%{"board" => "japan"})
    {:ok, _view, html} = live(conn, Routes.live_path(conn, SengokuWeb.GameLive, game_id))
    assert html =~ ~s(<div class="Game">)
  end

  @session Plug.Session.init(
             store: :cookie,
             key: "_app",
             encryption_salt: "secret",
             signing_salt: "secret",
             encrypt: false
           )

  defp setup_session(conn) do
    conn
    |> Plug.Session.call(@session)
    |> fetch_session()
  end

  test "joining a game when logged in uses your username", %{conn: conn} do
    user = Sengoku.AccountsFixtures.user_fixture(%{username: "tokugawa"})
    {:ok, game_id} = Sengoku.GameServer.new(%{"board" => "japan"})

    {:ok, view, _html} =
      conn
      |> setup_session()
      |> put_session(:player_id, user.id)
      |> live(Routes.live_path(conn, SengokuWeb.GameLive, game_id))

    refute has_element?(view, ~s([name="player_name"]))

    render_submit(view, :join)

    assert has_element?(view, ".Player.player-bg-1", user.username)
  end

  test "joining and playing a game", %{conn: conn} do
    {:ok, game_id} = Sengoku.GameServer.new(%{"board" => "japan"})
    {:ok, view, _html} = live(conn, Routes.live_path(conn, SengokuWeb.GameLive, game_id))

    # Ensure nothing on the board is interactive before the game starts
    refute has_element?(view, ~s([phx-click="place_unit"]))
    refute has_element?(view, ~s([phx-click="select_tile"]))
    refute has_element?(view, ~s([phx-click="start_move"]))
    refute has_element?(view, ~s([phx-click="attack"]))

    assert render(view) =~ "You are currently spectating. Join the game or wait and watch."
    refute has_element?(view, ~s([phx-click="start"]))

    render_submit(view, :join, %{"player_name" => "Yojimbo"})

    assert has_element?(view, ".Player.player-bg-1", "Yojimbo")

    assert render(view) =~
             "You’re in! Share the URL with a friend to invite them, or start the game when ready."

    render_click(element(view, ~s([phx-click="start"])))

    assert has_element?(view, ".player-bg-1 .Player-unplacedUnits", "3")
    assert render(view) =~ "You have 3 units to place"

    view
    |> first_matching_tile(~s([phx-click="place_unit"]))
    |> render_click

    assert has_element?(view, ".player-bg-1 .Player-unplacedUnits", "2")
    assert render(view) =~ "You have 2 units to place"

    view
    |> first_matching_tile(~s([phx-click="place_unit"]))
    |> render_click

    assert has_element?(view, ".player-bg-1 .Player-unplacedUnits", "1")
    assert render(view) =~ "You have 1 units to place"

    view
    |> first_matching_tile(~s([phx-click="place_unit"]))
    |> render_click

    refute has_element?(view, ".player-bg-1 .Player-unplacedUnits")
    assert render(view) =~ "Select one of your territories"

    view
    |> first_matching_tile(~s([phx-click="select_tile"]))
    |> render_click

    assert has_element?(view, ".Tile--selected")
    assert render(view) =~ "Select an adjacent territory"
  end

  test "the Region Bonuses module", %{conn: conn} do
    {:ok, game_id} = Sengoku.GameServer.new(%{"board" => "japan"})
    {:ok, view, html} = live(conn, Routes.live_path(conn, SengokuWeb.GameLive, game_id))

    assert html =~ "Region Bonuses"

    game_state = Sengoku.GameServer.get_state(game_id)
    game_state = put_in(game_state.tiles[49].owner, 1)
    game_state = put_in(game_state.tiles[50].owner, 1)
    game_state = put_in(game_state.tiles[58].owner, 1)
    game_state = put_in(game_state.tiles[59].owner, 1)
    send(view.pid, {:game_updated, game_state})

    assert has_element?(view, ".region-1.region-ownedby-1")
  end

  # element() requires a single match, but because tiles are assigned randomly,
  # we sometimes can’t uniquely identify a tile for the active player to
  # interact with, so this function returns the result of element() for the
  # first tile matching a selector
  #
  # Ultimately, I should have a predefined, deterministic game state for tests.
  #
  defp first_matching_tile(view, selector) do
    matching_tile_id =
      1..126
      |> Enum.to_list()
      |> Enum.find(fn tile_id ->
        has_element?(view, "#tile_#{tile_id}#{selector}")
      end)

    element(view, "#tile_#{matching_tile_id}")
  end
end
