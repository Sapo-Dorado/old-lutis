defmodule LutisWeb.PostLive do
  use LutisWeb, :live_view

  alias Lutis.Posts

  @load_amount 10

  def mount(_params, session, socket) do
    socket =
      case session["user_id"] do
        nil -> redirect(socket, to: Routes.login_path(socket, :index))
        _ -> socket
      end
    post = Posts.get_post_by_url_id(session["post_id"])
    socket = case Posts.get_batch(Posts.comment_stream(post), @load_amount) do
              {:ok, comments, comment_stream} ->
                socket |> assign(:comments, comments) |> assign(:comment_stream, comment_stream)
              _error ->
                socket |> assign(:comments, []) |> assign(:comment_stream, nil)
            end
    {:ok, socket
          |> assign(:session, session)
          |> assign(:upvoted?, Posts.has_upvoted?(session["user_id"], post))
          |> assign(:upvotes, Posts.count_upvotes(post))
          |> assign(:post, post)}
  end

  def handle_event("upvote", _params, socket) do
    post = socket.assigns.post
    session = socket.assigns.session
    Posts.create_upvote(post, session["user_id"])
    {:noreply, socket
               |> assign(:upvoted?, Posts.has_upvoted?(session["user_id"], post))
               |> assign(:upvotes, Posts.count_upvotes(post))}
  end

  def handle_event("comment", %{"comment" => %{"contents" => contents}}, socket) do
    post = socket.assigns.post
    session = socket.assigns.session
    case Posts.create_comment(contents, session["user_id"], post) do
      {:ok, comment} ->
        {:noreply, socket |> assign(:comments, [comment] ++ socket.assigns.comments)}
      _error ->
        {:noreply, socket}
    end
  end

  def handle_event("load_more", _params, socket) do
    comment_stream = socket.assigns.comment_stream
    case comment_stream do
      nil -> {:noreply, socket}
      _ ->
        case Posts.get_batch(comment_stream, @load_amount) do
          {:ok, new_comments, new_stream} ->
            {:noreply, socket
                       |> assign(:comments, socket.assigns.comments ++ new_comments)
                       |> assign(:comment_stream, new_stream)}
          _error -> {:noreply, socket}
        end
    end
  end

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

  def edit_button(assigns) do
    author = Posts.get_author(assigns.post)
    ~L"""
    <a href="<%=Routes.post_path(@socket, :edit, author, @post.url_id) %>" class="edit-post-button">
      <%= edit_icon() %>
    </a>
    """
  end

  def post_info(assigns) do
    ~L"""
    <p>Topic: <%= @post.topic%></p>
    <%= _ = form_for :upvote, "#", [phx_submit: "upvote"]%>
      <p class="post-info-text"> <%= view_icon() %>&nbsp;<%= @post.views %>
      <%=live_component @socket, LutisWeb.UpvoteComponent,
                                 upvoted?: @upvoted?%>
      <%= @upvotes %>
    </form>
    """
  end

  def comments(assigns) do
    ~L"""
    <%= f = form_for :comment, "#", [phx_submit: "comment"]%>
      <%= textarea(f, :contents) %>
      <%= submit "Comment", class: "btn btn-a btn-sm" %>
    </form>

    <%= for comment <- @comments do %>
      <%= show_comment(comment, assigns) %>
    <% end %>
    """
  end

  def show_comment(comment, assigns) do
    author = Posts.get_author(comment)
    ~L"""
    <%=author%>: <%=comment.contents%>
    <br>
    """
  end

  def edit_icon() do
    raw(~s(<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-edit-2"><path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path></svg>))
  end

  def view_icon() do
    raw(~s(<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-eye"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>))
  end


end
