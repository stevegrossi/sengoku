defmodule Sengoku.Email do
  import Bamboo.Email

  def confirmation_instructions(recipient_email, url) do
    base_email()
    |> to(recipient_email)
    |> subject("Confirm Your Sengoku Account")
    |> text_body("""
      Hi #{recipient_email},

      You can confirm your account by visiting the url below:

      #{url}

      If you didn't create an account with us, please ignore this.
    """)
  end

  def reset_password_instructions(recipient_email, url) do
    base_email()
    |> to(recipient_email)
    |> subject("Reset Your Sengoku Password")
    |> text_body("""
      Hi #{recipient_email},

      You can reset your password by visiting the url below:

      #{url}

      If you didn't request this change, please ignore this.
    """)
  end

  def update_email_instructions(recipient_email, url) do
    base_email()
    |> to(recipient_email)
    |> subject("Update Your Sengoku Email")
    |> text_body("""
      Hi #{recipient_email},

      You can change your e-mail by visiting the url below:

      #{url}

      If you didn't request this change, please ignore this.
    """)
  end

  defp base_email do
    new_email()
    |> from("admin@playsengoku.com")
  end
end
