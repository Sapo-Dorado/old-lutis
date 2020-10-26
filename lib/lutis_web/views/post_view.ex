defmodule LutisWeb.PostView do
  use LutisWeb, :view

  alias Lutis.{Posts,Accounts}

  def markdown(body) do
    body
    |> sanitize
    |> Earmark.as_html!
    |> fix_ampersands
    |> raw
  end

  defp sanitize(body) do
    body
    |> String.replace("<", "&lt;")
  end

  defp fix_ampersands(body) do
    String.replace(body, "&amp;", "&")
  end

  def delete_button(assigns, author) do
    icon = raw("<i data-feather=\"trash-2\"></i>")
    ~L"""
    <span>
      <%=link icon, to: Routes.post_path(@conn, :delete, author, @post.url_id), method: "delete", data: [confirm: "Delete this post?"], class: "delete-button"%>
    </span>
    """
  end

  def edit_button(assigns) do
    author = Posts.get_author(assigns.post)
    ~L"""
    <a href="<%=Routes.post_path(@conn, :edit, author, @post.url_id) %>" class="edit-post-button">
      <i data-feather="edit-2"></i>
    </a>
    """
  end

  def post_info(assigns, author) do
    upvote_icon = raw("<i data-feather=\"arrow-up\" width=\"20\" height=\"20\"></i>")
    downvote_icon = raw("<i data-feather=\"arrow-down\" width=\"20\" height=\"20\"></i>")
    ~L"""
    <p>Topic: <%= @post.topic%></p>
    <%= form_for @conn, Routes.post_path(@conn, :upvote, author, @post.url_id), fn _ -> %>
      <p class="post-info-text"> <i data-feather="eye" width="20" height="20"></i>&nbsp;<%= @post.views %>
      <%= if Lutis.Posts.has_upvoted?(@current_user, @post) do %>
        <%= submit downvote_icon, class: "btn btn-a btn-sm" %>
      <% else %>
        <%= submit upvote_icon, class: "btn btn-a btn-sm" %>
      <% end %>
      <%= Lutis.Posts.count_upvotes(@post)%></p>
    <% end %>
    """
  end

end
