defmodule Sengoku.Repo do
  use Ecto.Repo,
    otp_app: :sengoku,
    adapter: Ecto.Adapters.Postgres
end
