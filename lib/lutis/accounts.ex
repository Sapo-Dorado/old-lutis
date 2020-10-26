defmodule Lutis.Accounts do import Ecto.Query, warn: false
  alias Lutis.Repo

  alias Lutis.Accounts.{User, Credential}

  def list_users do
    User
    |> Repo.all()
    |> Repo.preload(:credential)
  end

  def get_user(id) do
    User
    |> Repo.get(id)
    |> Repo.preload(:credential)
  end

  def get_user_id(name) do
    case(User
        |> Ecto.Query.where(username: ^name)
        |> Repo.one) do
      nil -> nil
      user -> user.id
    end
  end

  def get_username(id) do
    case get_user(id) do
      nil -> nil
      user -> user.username
    end
  end

  def verify_user(conn) do
    case Plug.Conn.get_session(conn, :user_id) do
      nil -> nil
      user_id ->
        case Repo.get(User, user_id) do
          nil -> nil
          user -> user.id
        end
    end
  end

  def create_user(attrs \\ %{}) do
    user_info = attrs
                |> Map.put("account_created", NaiveDateTime.utc_now)
                |> Map.put("last_login", NaiveDateTime.utc_now)

    %User{}
    |> User.changeset(user_info)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
    |> Repo.insert()
  end

  def update_pw(%User{} = user, %{"credential" => %{"old_password" => old_password}} = attrs) do
    changeset = user
                |> User.changeset(attrs)
                |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
    Repo.update(case authenticate_by_email_password(user.credential.email, old_password) do
                  {:ok, _user} -> changeset
                  {:error, :unauthorized} ->
                    Ecto.Changeset.add_error(changeset, :old_password, "Incorrect password")
                end)
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
        if Argon2.verify_pass(password, user.credential.password_hash) do
          {:ok, user}
        else
          {:error, :unauthorized}
        end
    end
  end

  def update_login(user) do
    update_user(user, %{last_login: NaiveDateTime.utc_now})
  end
end
