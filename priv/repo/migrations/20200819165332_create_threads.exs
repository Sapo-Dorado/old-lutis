defmodule Lutis.Repo.Migrations.CreateThreads do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :user1, :integer
      add :user2, :integer

      timestamps()
    end

  end
end
