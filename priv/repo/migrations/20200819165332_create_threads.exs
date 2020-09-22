defmodule Lutis.Repo.Migrations.CreateThreads do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :user1, :integer
      add :user2, :integer
      add :user1read, :utc_datetime
      add :user2read, :utc_datetime
      add :lastmessage, :utc_datetime

      timestamps()
    end

  end
end
