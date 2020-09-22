defmodule LutisWeb.UnreadMessageComponent do
  use LutisWeb, :live_component

  def update(%{id: id, thread: thread, user_id: user_id, unread: unread}, socket) do
    LutisWeb.Endpoint.subscribe("message_#{thread.id}")
    {:ok, socket
          |> assign(:id, id)
          |> assign(:thread, thread)
          |> assign(:user_id, user_id)
          |> assign(:unread, unread)}
  end

  def handle_info(%{event: "new_message"}, socket) do
    LutisWeb.Endpoint.broadcast_from!(self(), "thread_#{socket.assigns.user_id}", "new_message", nil)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <%= if @unread do %>
      <td><p>dot<p></td>
    <% else %>
      <td><p><p></td>
    <% end %>
    """
  end
end
