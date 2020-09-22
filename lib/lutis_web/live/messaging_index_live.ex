defmodule LutisWeb.MessagingIndexLive do
  use LutisWeb, :live_view

  alias Lutis.Messaging

  def mount(_assigns, session, socket) do
    case session["user_id"] do
      nil -> redirect(socket, to: Routes.login_path(socket, :index))
      _ ->
        threads = Messaging.list_threads(session["user_id"])
        LutisWeb.Endpoint.subscribe("thread_#{session["user_id"]}")
        {:ok, socket
              |> assign(:user_id, session["user_id"])
              |> assign(:threads, threads)}
    end
  end

  def handle_info(%{event: "new_message"}, socket) do
    {:noreply, socket |> assign(:threads, Messaging.list_threads(socket.assigns.user_id))}
  end
end
