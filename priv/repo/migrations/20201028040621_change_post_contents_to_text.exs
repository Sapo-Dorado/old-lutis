defmodule Lutis.Repo.Migrations.ChangePostContentsToText do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      modify :contents, :text
    end
  end
end
