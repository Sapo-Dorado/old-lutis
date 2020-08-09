defmodule Lutis.Accounts do

  import Ecto.Query, warn: false
  alias Lutis.Repo

  alias Lutis.Accounts.{User, Credential}

  def list_users do
    User
    |> Repo.all()
    |> Repo.preload(:credential)
  end

  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:credential)
  end

  def create_user(attrs \\ %{}) do
    IO.inspect(attrs)
    user_info = (attrs
                |> Map.put("account_created", NaiveDateTime.utc_now)
                |> Map.put("last_login", NaiveDateTime.utc_now))

    %User{}
    |> User.changeset(user_info)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def list_credentials do
    Repo.all(Credential)
  end

  def get_credential!(id), do: Repo.get!(Credential, id)

  def create_credential(attrs \\ %{}) do
    %Credential{}
    |> Credential.changeset(attrs)
    |> Repo.insert()
  end

  def update_credential(%Credential{} = credential, attrs) do
    credential
    |> Credential.changeset(attrs)
    |> Repo.update()
  end

  def delete_credential(%Credential{} = credential) do
    Repo.delete(credential)
  end

  def change_credential(%Credential{} = credential, attrs \\ %{}) do
    Credential.changeset(credential, attrs)
  end

  def permissions_level(title) do
    case title do
      "owner" -> 4
      "admin" -> 3
      "mod" -> 2
      "user" -> 1
    end
  end

  def authenticate_by_email_password(email, password) do
    query =
      from u in User,
        inner_join: c in assoc(u, :credential),
        where: c.email == ^email

    case query |> Repo.one() |> Repo.preload(:credential) do
      nil -> {:error, :unauthorized}
      user ->
        if user.credential.password == password do
          {:ok, user}
        else
          {:error, :unauthorized}
        end
    end
  end

end
