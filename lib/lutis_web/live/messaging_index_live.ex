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
              |> assign(:session, session)
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
    user1 = Lutis.Accounts.get_username(thread.user1)
    user2 = Lutis.Accounts.get_username(thread.user2)
    recipient = if thread.user2 == assigns.user_id, do: user1, else: user2
    ~L"""
    <article class="post-entry">
      <section class="entry-header">
        <a class="unread-icon">
          <%=live_component @socket, LutisWeb.UnreadMessageComponent,
                                     id: "#{thread.id}-#{@user_id}",
                                     thread: thread,
                                     user_id: @user_id,
                                     unread: Lutis.Messaging.has_unread_message?(thread, @user_id)%>
        </a><h2><%= recipient %></h2>
      </section>
      <a class = "entry-link" href="<%= Routes.live_path(@socket, LutisWeb.MessagingLive, recipient)%>#view"></a>
    </article>
    """
  end
end
