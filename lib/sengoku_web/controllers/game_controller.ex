defmodule SengokuWeb.GameController do
  use SengokuWeb, :controller

  alias Sengoku.GameServer

  @modes ~w(hot_seat online)

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"mode" => mode}) when mode in @modes do
    {:ok, game_id} = GameServer.new(String.to_atom(mode))
    redirect conn, to: "/#{game_id}"
  end

  def show(conn, %{"game_id" => game_id}) do
    conn
    |> put_layout("game.html")
    |> render("show.html", %{game_id: game_id})
  end
end
