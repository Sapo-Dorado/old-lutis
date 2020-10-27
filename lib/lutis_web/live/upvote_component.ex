defmodule LutisWeb.UpvoteComponent do
  use LutisWeb, :live_component

  def update(%{upvoted?: upvoted?}, socket) do
    {:ok, socket
          |> assign(:upvoted?, upvoted?)}
  end

  def render(assigns) do
    ~L"""
      <%= if @upvoted? do %>
        <%= submit downvote_icon(), class: "btn btn-sm" %>
      <% else %>
        <%= submit upvote_icon(), class: "btn btn-sm" %>
      <% end %>
      """
  end

  def upvote_icon() do
    raw(~s(<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-up"><line x1="12" y1="19" x2="12" y2="5"></line><polyline points="5 12 12 5 19 12"></polyline></svg>))
  end

  def downvote_icon() do
    raw(~s(<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-down"><line x1="12" y1="5" x2="12" y2="19"></line><polyline points="19 12 12 19 5 12"></polyline></svg>))
  end

end

