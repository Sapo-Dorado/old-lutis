defmodule LutisWeb.PostIndexLive do
  use LutisWeb, :live_view

  alias Lutis.{Posts,Accounts}

  @load_amount 5

  def mount(assigns, session, socket) do
    socket =
      case session["user_id"] do
        nil -> redirect(socket, to: Routes.login_path(socket, :index))
        _ -> socket
      end
    socket = case assigns do
      %{"search" => %{"query" => query, "order" => order}} ->
        socket
        |> assign(:query, query)
        |> assign(:order, order)
      _ ->
        socket
        |> assign(:query, nil)
        |> assign(:order, nil)
    end
    case Posts.get_batch(Posts.post_stream(assigns), @load_amount) do
      {:ok, posts, post_stream} ->
        {:ok, socket
              |> assign(:posts, posts)
              |> assign(:post_stream, post_stream)}
      {:error, _} -> {:ok, socket |> redirect(to: Routes.home_page_path(socket, :index))}
    end
  end

  def handle_event("load_more", _, socket) do
    case socket.assigns.post_stream do
      nil -> {:noreply, socket}
      _ ->
        case Posts.get_batch(socket.assigns.post_stream, @load_amount) do
          {:ok, posts, post_stream} ->
            {:noreply, socket
                       |> assign(:posts, socket.assigns.posts ++ posts)
                       |> assign(:post_stream, post_stream)}
          {:error, _} -> {:noreply, socket}
        end
    end
  end

  def showPost(post, assigns) do
    author = Posts.get_author(post)
    ~L"""
    <article class="post-entry">
      <div class="entry-header"><h2><%= post.title %></h2></div>
      <section class="entry-content">
        <%= post.topic %>
      </section>
      <section class="entry-footer">
        <%= eye_icon() %> &nbsp;<%= post.views %>
        &ensp; <%= upvote_icon() %>
        &nbsp;<%= Lutis.Posts.count_upvotes(post) %>
      </section>
      <a class="entry-link" href="<%=Routes.post_path(@socket, :show, author, post.url_id)%>"></a>
    </article>
    """
  end

  def eye_icon() do
    raw(~s(<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-eye"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>))
  end

  def upvote_icon() do
    raw(~s(<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-arrow-up"><line x1="12" y1="19" x2="12" y2="5"></line><polyline points="5 12 12 5 19 12"></polyline></svg>))
  end

end
