defmodule Lutis.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  alias Lutis.Accounts.User

  schema "credentials" do
    field :email, :string
    field :password, :string
    field :permissions_level, :integer
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email, :password, :permissions_level])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
  end

end
