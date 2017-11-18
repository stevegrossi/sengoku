defmodule SengokuWeb.AcceptanceTest do
    use SengokuWeb.BrowserCase, async: true
  
    import Wallaby.Query, only: [css: 2]
  
    test "users have names", %{session: session} do
      session
      |> visit("/")
      assert 4 == 5
    end
  end