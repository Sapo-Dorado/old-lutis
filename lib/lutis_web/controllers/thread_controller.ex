defmodule LutisWeb.ThreadController do
  use LutisWeb, :controller

  alias Lutis.Messaging
  alias Lutis.Messaging.Thread
  alias Lutis.Accounts

  def new(conn, _params) do
    changeset = Messaging.change_thread(%Thread{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"thread" => params}) do
    thread_params = (params
                    |> Map.put("user_id", conn.assigns.current_user)
                    |> Map.put("recipient_id", Accounts.get_user_id(params["recipient"])))
    case Messaging.create_thread(thread_params) do
      {:ok, _thread} ->
        conn
        |> redirect(to: "#{Routes.live_path(conn, LutisWeb.MessagingLive, thread_params["recipient"])}#view")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"recipient" => recipient}) do
    recipient_id = Accounts.get_user_id(recipient)
    thread = Messaging.get_thread(conn.assigns.current_user, recipient_id)
    {:ok, _thread} = Messaging.delete_thread(thread)
    conn
    |> put_flash(:info, "Thread deleted successfully.")
    |> redirect(to: Routes.thread_path(conn, :index))
  end
end
