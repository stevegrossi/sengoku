defmodule Sengoku.Repo.Migrations.AddUsernameToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :username, :citext, null: false
    end
    create index("users", [:username], unique: true)
  end
end
