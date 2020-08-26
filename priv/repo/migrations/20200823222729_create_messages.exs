defmodule Lutis.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :author, :integer
      add :contents, :string
      add :time_sent, :utc_datetime
      add :thread_id, references(:threads, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:messages, [:thread_id])
  end
end
