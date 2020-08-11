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
  def changeset(credential, %{"password" => password} = attrs) do
    credential
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> change(Argon2.add_hash(password))
  end

end
