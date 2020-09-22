defmodule Lutis.Messaging.Thread do
  use Ecto.Schema
  import Ecto.Changeset

  alias Lutis.Messaging.Message

  schema "threads" do
    field :user1, :integer
    field :user2, :integer
    field :user1read, :utc_datetime
    field :user2read, :utc_datetime
    field :lastmessage, :utc_datetime
    has_many :messages, Message

    timestamps()
  end

  @doc false
  def changeset(thread, attrs) do
    thread
    |> cast(attrs, [:user1, :user2, :user1read, :user2read, :lastmessage])
    |> validate_required([:user1, :user2], message: "Invalid recipient")
  end
end
