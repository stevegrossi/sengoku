defmodule SengokuWeb.PageControllerTest do
  use SengokuWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Sengoku"
  end
end
