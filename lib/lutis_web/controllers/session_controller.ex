defmodule LutisWeb.SessionController do
  use LutisWeb, :controller

  alias Lutis.Accounts

  def create(conn, %{"user" => %{"email" => email, "password" => password}, "req" => req}) do
    case Accounts.authenticate_by_email_password(email, password) do
      {:ok, user} ->
        Accounts.update_login(user)
        conn
        |> put_flash(:info, "Welcome Back!")
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: req)
      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "Bad email/password combination")
        |> redirect(to: Routes.login_path(conn, :index, req: req))
    end
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
