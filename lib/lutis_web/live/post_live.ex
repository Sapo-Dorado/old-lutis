defmodule LutisWeb.PostLive do
  use LutisWeb, :live_view

  alias Lutis.{Posts,Accounts}

  @load_amount 10

  def mount(_params, session, socket) do
    post = Posts.get_post_by_url_id(session["post_id"])
    socket = case Posts.get_batch(Posts.comment_stream(post), @load_amount) do
              {:ok, comments, comment_stream} ->
                socket |> assign(:comments, comments) |> assign(:comment_stream, comment_stream)
              _error ->
                socket |> assign(:comments, []) |> assign(:comment_stream, nil)
            end
    user_id = session["user_id"]
    {:ok, socket
          |> assign(:session, session)
          |> assign(:user_id, user_id)
          |> assign(:upvoted?, Posts.has_upvoted?(user_id, post))
          |> assign(:upvotes, Posts.count_upvotes(post))
          |> assign(:post, post)}
  end

  def handle_event("upvote", _params, socket) do
    post = socket.assigns.post
    user_id = socket.assigns.user_id
    if(!is_nil(user_id)) do
      Posts.create_upvote(post, user_id)
      {:noreply, socket
                 |> assign(:upvoted?, Posts.has_upvoted?(user_id, post))
                 |> assign(:upvotes, Posts.count_upvotes(post))}
    else
      {:noreply, socket}
    end
  end

  def handle_event("comment", %{"comment" => %{"contents" => contents}}, socket) do
    post = socket.assigns.post
    user_id = socket.assigns.user_id
    if(!is_nil(user_id)) do
      case Posts.create_comment(contents, user_id, post) do
        {:ok, comment} ->
          {:noreply, socket |> assign(:comments, [comment] ++ socket.assigns.comments)}
        _error ->
          {:noreply, socket}
      end
    else
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
    |> convert_md_to_html
    |> fix_ampersands
    |> raw
  end

  defp sanitize(body) do
    body
    |> String.replace("<", "&lt;")
  end

  defp convert_md_to_html(content) do
    content
    |> convert_video
    |> Earmark.as_html!
  end

  def convert_video(body) do
    video_regex = ~r/!\[.*\]\(https:\/\/www\.youtube\.com\/watch\?v=(.{11})&?(.*)\)|!\[.*\]\(https:\/\/youtu\.be\/(.{11})\??(.*)\)/
    Regex.replace(video_regex, body, &video_replace_func/5)
  end

  def video_replace_func(_, key1,ext1,key2,ext2) do
    url_end = key1 <> key2 <> cond do
                                ext1 != "" -> "?#{ext1}"
                                ext2 != "" -> "?#{ext2}"
                                true -> ""
                              end
    url_end = Regex.replace(~r{t=([0-9]+)s}, url_end, "start=\\1")
    ~s(<iframe width="560" height="315" src="https://www.youtube.com/embed/#{url_end}" frameborder="0" allowfullscreen="true"></iframe>)
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
      <%= if !is_nil(@user_id) do %>
        <%=live_component @socket, LutisWeb.UpvoteComponent,
                                   upvoted?: @upvoted?%>
      <% else %>
        <%= upvote_icon() %>
      <% end %>
      <%= @upvotes %>
    </form>
    """
  end
  def comment_area(assigns) do
    ~L"""
    <%= if !is_nil(@user_id) do %>
      <%= f = form_for :comment, "#", [phx_submit: "comment"]%>
        <%= textarea(f, :contents) %>
        <%= submit "Comment", class: "btn btn-a btn-sm" %>
      </form>
    <% end %>
    """
  end

  def show_comment(comment, assigns) do
    author = Posts.get_author(comment)
    color = Accounts.get_color(comment.author)
    ~L"""
    <div class="post-entry">
      <strong style="color:<%=color%>;"><%=author%>:</strong>
      <p><%=comment.contents%></p>
    </div>
    """
  end

  def edit_icon() do
    raw(~s(<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-edit-2"><path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path></svg>))
  end

  def view_icon() do
    raw(~s(<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-eye"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>))
  end

  def upvote_icon() do
    raw(~s(<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-up"><line x1="12" y1="19" x2="12" y2="5"></line><polyline points="5 12 12 5 19 12"></polyline></svg>))
  end

end
