defmodule Lutis.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
  use PhoenixHtmlSanitizer, :strip_tags

  alias Lutis.Posts.Upvote

  schema "posts" do
    field :author, :integer
    field :contents, :string
    field :topic, :string
    field :title, :string
    field :views, :integer
    field :upvotes, :integer
    field :url_id, :integer
    has_many :user_upvotes, Upvote

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:author, :topic, :title, :contents, :url_id])
    |> validate_required([:author, :topic, :title, :contents])
  end

  @doc false
  def upvoteChangeset(post, attrs) do
    post
    |> cast(attrs, [:upvotes])
  end
end
