defmodule SengokuWeb.Router do
  use SengokuWeb, :router

  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SengokuWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SengokuWeb.Plug.IdentifyAnonymousUser
  end

  pipeline :admins_only do
    if Mix.env() == :prod do
      creds =
        System.get_env("ADMIN_CREDS") || raise("You must set ADMIN_CREDS in the environment")

      [username, password] = String.split(creds, ":")
      plug :basic_auth, username: username, password: password
    end
  end

  scope "/", SengokuWeb do
    pipe_through :browser

    get "/", GameController, :new
    post "/games", GameController, :create
    live "/games/:game_id", GameLive, layout: {SengokuWeb.LayoutView, :game}
    live "/builder", BoardBuilderLive, layout: {SengokuWeb.LayoutView, :game}
  end

  scope "/" do
    pipe_through [:browser, :admins_only]

    live_dashboard "/dashboard", metrics: SengokuWeb.Telemetry
  end
end
