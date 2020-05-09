defmodule SengokuWeb.Plug.IdentifyAnonymousUser do

  def init(options), do: options

  def call(conn, opts) do
    if Plug.Conn.get_session(conn, :anonymous_user_id) do
      conn
    else
      conn
      |> Plug.Conn.put_session(:anonymous_user_id, Ecto.UUID.generate)
    end
  end
end
