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
  def update_threads(socket) do
    socket |> assign(:threads, Messaging.list_threads(socket.assigns.user_id))
  end

  def handle_info(%{event: "new_thread"}, socket) do
    {:noreply, update_threads(socket)}
  end

  def handle_info(%{event: "delete_thread"}, socket) do
    {:noreply, update_threads(socket)}
  end

  def handle_info(%{event: "new_message"}, socket) do
    {:noreply, update_threads(socket)}
  end

  def show_thread(assigns, thread) do
    user1 = Lutis.Accounts.get_username!(thread.user1)
    user2 = Lutis.Accounts.get_username!(thread.user2)
    recipient = if thread.user2 == assigns.user_id, do: user1, else: user2
    ~L"""
    <a class="unread-icon">
      <%=live_component @socket, LutisWeb.UnreadMessageComponent,
                                 id: "#{thread.id}-#{@user_id}",
                                 thread: thread,
                                 user_id: @user_id,
                                 unread: Lutis.Messaging.has_unread_message?(thread, @user_id)%>
    </a>
    <a href="<%= Routes.live_path(@socket, LutisWeb.MessagingLive, recipient)%>#view" class="info-button thread-button">
        <%= recipient %>
    </a>
    <%= delete_button(assigns, recipient) %>
    """
  end

  defp delete_button(assigns, recipient) do
    icon = raw(~s(<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="red" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-trash-2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>))
    ~L"""
    <span><%= link icon, to: Routes.thread_path(@socket, :delete, recipient), method: :delete, data: [confirm: "Are you sure?"], class: "delete-button"%></span>
    """
  end

end
