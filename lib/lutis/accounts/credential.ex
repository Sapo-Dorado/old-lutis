defmodule Lutis.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  alias Lutis.Accounts.User

  schema "credentials" do
    field :email, :string
    field :password_hash, :string
    field :permissions_level, :integer
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(credential, %{"password" => password} = attrs) do
    credential
    |> cast(Map.put(attrs, "password_hash", password), [:email, :password_hash])
    |> unique_constraint(:email)
    |> validate_required([:email, :password_hash])
    |> validate_length(:password_hash, min: 6)
    |> validate_confirmation(:password_hash, message: "passwords do not match")
    |> change(Argon2.add_hash(password))
  end

end
