defmodule Sengoku.Accounts.UserNotifier do
  alias Sengoku.{Email, Mailer}

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    mail = Email.confirmation_instructions(user.email, url)
    Mailer.deliver_later(mail)

    {:ok, %{to: user.email, body: mail.text_body}}
  end

  @doc """
  Deliver instructions to reset password account.
  """
  def deliver_reset_password_instructions(user, url) do
    mail = Email.reset_password_instructions(user.email, url)
    Mailer.deliver_later(mail)

    {:ok, %{to: user.email, body: mail.text_body}}
  end

  @doc """
  Deliver instructions to update your e-mail.
  """
  def deliver_update_email_instructions(user, url) do
    mail = Email.update_email_instructions(user.email, url)
    Mailer.deliver_later(mail)

    {:ok, %{to: user.email, body: mail.text_body}}
  end
end
