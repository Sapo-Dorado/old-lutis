defmodule Lutis.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Lutis.Accounts.Credential

  schema "users" do
    field :account_created, :utc_datetime
    field :color, :string
    field :last_login, :utc_datetime
    field :username, :string
    has_one :credential, Credential

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :color, :account_created, :last_login])
    |> validate_required([:username, :color, :account_created, :last_login])
    |> unique_constraint(:username)
  end
end
