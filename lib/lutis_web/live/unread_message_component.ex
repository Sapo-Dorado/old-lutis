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

  def render(assigns) do
    ~L"""
    <%= if @unread do %>
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-bell"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
    <% else %>
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-bell"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
    <% end %>
    """
  end
end
