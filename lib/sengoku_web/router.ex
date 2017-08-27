defmodule SengokuWeb.Router do
  use SengokuWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SengokuWeb do
    pipe_through :browser # Use the default browser stack

    get "/", GameController, :index
    post "/", GameController, :create
    get "/:game_id", GameController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", SengokuWeb do
  #   pipe_through :api
  # end
end
