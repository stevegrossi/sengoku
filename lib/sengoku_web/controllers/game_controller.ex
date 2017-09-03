defmodule SengokuWeb.GameController do
  use SengokuWeb, :controller

  alias Sengoku.GameServer

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"mode" => mode}) when mode in ~w(hot_seat online) do
    {:ok, game_id} = GameServer.new
    redirect conn, to: "/#{game_id}"
  end

  def show(conn, %{"game_id" => game_id}) do
    render conn, "show.html", %{game_id: game_id}
  end
end
