defmodule Lutis.Repo.Migrations.CreateThreads do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :user1read, :utc_datetime
      add :user2read, :utc_datetime
      add :lastmessage, :utc_datetime
      add :user1, references(:users, on_delete: :delete_all), null: false
      add :user2, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

  end
end
