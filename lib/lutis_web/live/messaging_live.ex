defmodule LutisWeb.MessagingLive do
  use LutisWeb, :live_view

  alias Lutis.Messaging
  alias Lutis.Accounts

  @load_amount 200

  def mount(%{"recipient" => recipient}, session, socket) do
    socket =
      case session["user_id"] do
        nil -> redirect(socket, to: Routes.login_path(socket, :index))
        _ -> socket
      end
    thread = Messaging.get_thread(session["user_id"], Accounts.get_user_id(recipient))
    LutisWeb.Endpoint.subscribe("message_#{thread.id}")
    Messaging.mark_as_read(thread, session["user_id"])
    case Messaging.get_batch(Messaging.message_stream(thread), @load_amount) do
      {:ok, message_list, message_stream} -> 
        {:ok, socket
              |> assign(:messages, message_list)
              |> assign(:recipient, recipient)
              |> assign(:user_id, session["user_id"])
              |> assign(:message_stream, message_stream)}
      {:error, _} -> redirect(socket, to: Routes.thread_path(socket, :index))
    end
  end

  def handle_event("send_message", %{"message" => %{"contents" => contents}}, socket) do
    recipient_id = Accounts.get_user_id(socket.assigns.recipient)
    thread = Messaging.get_thread(socket.assigns.user_id, recipient_id)
    message_params = %{
      "author" => socket.assigns.user_id,
      "contents" => contents,
      "thread_id" => thread.id
    }
    case Messaging.create_message(thread, message_params) do
      {:ok, new_message} ->
        LutisWeb.Endpoint.broadcast_from!(self(),"message_#{thread.id}", "new_message", new_message)
        updated_messages = socket.assigns.messages ++ [new_message]
        Messaging.mark_as_read(thread, socket.assigns.user_id)
        {:noreply, socket |> assign(:messages, updated_messages)}
      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("load_messages", _attrs, socket) do
    case socket.assigns.message_stream do
      nil -> {:noreply, socket}
      _ -> 
        case Messaging.get_batch(socket.assigns.message_stream, @load_amount) do
          {:ok, new_messages, message_stream} -> 
                {:noreply, socket
                            |> assign(:messages, new_messages ++ socket.assigns.messages)
                            |> assign(:message_stream, message_stream)}
          {:error, _} -> {:noreply, socket}
        end
    end
  end

  def handle_info(%{event: "new_message", payload: new_message}, socket) do
    recipient_id = Accounts.get_user_id(socket.assigns.recipient)
    thread = Messaging.get_thread(socket.assigns.user_id, recipient_id)
    Messaging.mark_as_read(thread, socket.assigns.user_id)
    updated_messages = socket.assigns.messages ++ [new_message]
    {:noreply, socket |> assign(:messages, updated_messages)}
  end

  def handle_info(%{event: "delete_thread"}, socket) do
    {:noreply, socket
               |> put_flash(:error, "#{socket.assigns.recipient} has deleted the thread")
               |> redirect(to: Routes.live_path(socket, LutisWeb.MessagingIndexLive))}
  end
end
