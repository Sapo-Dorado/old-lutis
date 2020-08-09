defmodule Lutis.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :color, :string
      add :account_created, :utc_datetime
      add :last_login, :utc_datetime

      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
