defmodule SengokuWeb.Router do
  use SengokuWeb, :router

  import SengokuWeb.UserAuth

  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SengokuWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug SengokuWeb.Plugs.PutPlayerID
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

    # Accounts
    delete "/users/logout", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm

    # Games
    get "/", GameController, :new
    post "/games", GameController, :create
    live "/games/:game_id", GameLive, layout: {SengokuWeb.LayoutView, :game}
    live "/builder", BoardBuilderLive, layout: {SengokuWeb.LayoutView, :game}
  end

  scope "/" do
    pipe_through [:browser, :admins_only]

    live_dashboard "/dashboard", metrics: SengokuWeb.Telemetry
  end

  ## Authentication routes

  scope "/", SengokuWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/login", UserSessionController, :new
    post "/users/login", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", SengokuWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings/update_password", UserSettingsController, :update_password
    put "/users/settings/update_email", UserSettingsController, :update_email
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end
end
