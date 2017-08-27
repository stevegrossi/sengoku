defmodule SengokuWeb.GameController do
  use SengokuWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def create(conn, _params) do
    {:ok, game_id} = Sengoku.GameServer.new
    redirect conn, to: "/#{game_id}"
  end

  def show(conn, %{"game_id" => game_id}) do
    render conn, "show.html", %{game_id: game_id}
  end
end
