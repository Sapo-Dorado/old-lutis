defmodule Lutis.Posts.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :contents, :string
    field :author, :integer
    field :post_id, :id

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:contents, :author, :post_id])
    |> validate_required([:contents])
  end
end
