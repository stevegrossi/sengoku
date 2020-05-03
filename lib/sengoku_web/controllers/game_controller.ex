defmodule SengokuWeb.GameController do
  use SengokuWeb, :controller

  alias Sengoku.GameServer

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"board" => _board} = options) do
    {:ok, game_id} = GameServer.new(options)
    redirect(conn, to: "/game/#{game_id}")
  end
end
