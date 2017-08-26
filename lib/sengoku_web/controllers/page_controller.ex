defmodule SengokuWeb.PageController do
  use SengokuWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
