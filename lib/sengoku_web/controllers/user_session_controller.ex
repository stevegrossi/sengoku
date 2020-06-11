defmodule SengokuWeb.UserSessionController do
  use SengokuWeb, :controller

  alias Sengoku.Accounts
  alias SengokuWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email_or_username" => email_or_username, "password" => password} = user_params
    user =
      if String.contains?(email_or_username, "@") do
        Accounts.get_user_by_email_and_password(email_or_username, password)
      else
        Accounts.get_user_by_username_and_password(email_or_username, password)
      end

    if user do
      UserAuth.login_user(conn, user, user_params)
    else
      render(conn, "new.html", error_message: "Invalid e-mail or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.logout_user()
  end
end
