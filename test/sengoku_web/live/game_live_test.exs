defmodule SengokuWeb.GameLiveTest do
  use SengokuWeb.ConnCase
  import Phoenix.LiveViewTest
  @endpoint SengokuWeb.Endpoint

  test "connected mount", %{conn: conn} do
    {:ok, game_id} = Sengoku.GameServer.new(%{"board" => "japan"})
    {:ok, _view, html} = live(conn, "/game/#{game_id}")
    assert html =~ ~s(<div class="Game">)
  end

  test "joining a game", %{conn: conn} do
    {:ok, game_id} = Sengoku.GameServer.new(%{"board" => "japan"})
    {:ok, view, _html} = live(conn, "/game/#{game_id}")

    # Ensure nothing on the board is interactive before the game starts
    refute has_element?(view, ~s([phx-click="place_unit"]))
    refute has_element?(view, ~s([phx-click="select_tile"]))
    refute has_element?(view, ~s([phx-click="start_move"]))
    refute has_element?(view, ~s([phx-click="attack"]))

    render_submit(view, :join, %{"player_name" => "Yojimbo"})

    assert has_element?(view, ".Player.player-bg-1", "Yojimbo")

    render_click(view, :start)

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
      |> Enum.find(fn(tile_id) ->
          has_element?(view, "#tile_#{tile_id}#{selector}")
         end)

    element(view, "#tile_#{matching_tile_id}")
  end
end
