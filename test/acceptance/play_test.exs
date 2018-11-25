defmodule Sengoku.AccountManagementTest do
  use SengokuWeb.AcceptanceCase

  test "Playing a game", %{session: session} do
    session
    |> visit("/")
    |> assert_has(css("h2", text: "PLAY"))
    |> accept_prompt([with: "Yojimbo"], fn(session) ->
        click(session, button("New Game"))
       end)

    session
    |> assert_has(css(".Player", text: "Yojimbo"))
    # |> fill_in(text_field("Email"), with: account.email)
    # |> fill_in(text_field("Password"), with: "password")
    # |> click(button("Log In"))
    # |> click(link("Me"))
    # |> assert_has(css("h2", text: account.email))
  end
end
