defmodule SengokuWeb.Router do
  use SengokuWeb, :router

pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SengokuWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", SengokuWeb do
    pipe_through :browser

    get "/", GameController, :new
    post "/", GameController, :create
    live "/game/:game_id", GameLive
  end
end
