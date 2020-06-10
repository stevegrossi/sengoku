defmodule SengokuWeb.Plugs.PutPlayerIDTest do
  use SengokuWeb.ConnCase

  alias SengokuWeb.Plugs.PutPlayerID

  @opts PutPlayerID.init([])
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

  test "errors when assigns.current_user is missing", %{conn: conn} do
    assert_raise FunctionClauseError, fn ->
      conn
      |> setup_session()
      |> PutPlayerID.call(@opts)
    end
  end

  test "stores an anonymous ID when the user is unrecognized", %{conn: conn} do
    conn =
      conn
      |> setup_session()
      |> Plug.Conn.assign(:current_user, nil)
      |> PutPlayerID.call(@opts)

    assert String.starts_with?(get_session(conn)["player_id"], "anonymous-")
  end

  test "stores the current_user’s ID when present", %{conn: conn} do
    conn =
      conn
      |> setup_session()
      |> Plug.Conn.assign(:current_user, %{id: 123})
      |> PutPlayerID.call(@opts)

    assert get_session(conn)["player_id"] == 123
  end
end
