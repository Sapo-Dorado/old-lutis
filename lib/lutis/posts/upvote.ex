defmodule Lutis.Posts.Upvote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "upvotes" do
    field :time, :utc_datetime
    field :user, :integer
    field :post_id, :id

    timestamps()
  end

  @doc false
  def changeset(upvote, attrs) do
    upvote
    |> cast(attrs, [:time, :user, :post_id])
    |> validate_required([:time, :user, :post_id])
  end
end
