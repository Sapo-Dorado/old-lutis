defmodule Lutis.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :author, :integer
      add :topic, :string
      add :title, :string
      add :contents, :string
      add :views, :integer, default: 0
      add :url_id, :integer

      timestamps()
    end

  end
end
