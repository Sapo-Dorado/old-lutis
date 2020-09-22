defmodule Lutis.Repo.Migrations.CreateUpvotes do
  use Ecto.Migration

  def change do
    create table(:upvotes) do
      add :time, :utc_datetime
      add :user, :integer
      add :post_id, references(:posts, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:upvotes, [:post_id])
  end
end
