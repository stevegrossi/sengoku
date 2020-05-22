defmodule Sengoku.PlayTest do
  use SengokuWeb.AcceptanceCase

  test "Playing a game", %{session: session} do
    session
    |> visit("/")
    |> assert_has(css("h2", text: "PLAY"))
    |> accept_prompt([with: "Yojimbo"], fn session ->
      click(session, button("New Game"))
    end)

    session
    |> assert_has(css(".Player", count: 4))
    |> assert_has(css(".Player", count: 1, text: "Yojimbo"))
  end
end
