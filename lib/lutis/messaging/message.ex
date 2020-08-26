defmodule Lutis.Messaging.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Lutis.Messaging.Thread

  schema "messages" do
    field :author, :integer
    field :contents, :string
    field :time_sent, :utc_datetime
    belongs_to :thread, Thread

    timestamps()
  end


  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:author, :contents, :time_sent, :thread_id])
    |> validate_required([:author, :contents, :time_sent, :thread_id])
  end
end
