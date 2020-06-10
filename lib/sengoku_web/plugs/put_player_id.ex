defmodule SengokuWeb.Plugs.PutPlayerID do
  @moduledoc """
  Ensures every client has a unique player_id in the session which GameLive can
  use to uniquely identify players.
  """

  alias Sengoku.Token

  def init(options), do: options

  def call(%{assigns: %{current_user: current_user}} = conn, _opts) do
    existing_player_id = Plug.Conn.get_session(conn, :player_id)

    case {current_user, existing_player_id} do
      {nil, nil} ->
        Plug.Conn.put_session(conn, :player_id, "anonymous-#{Token.new()}")

      {%{id: user_id}, id} when user_id != id ->
        Plug.Conn.put_session(conn, :player_id, user_id)

      {_, _} ->
        conn
    end
  end
end
