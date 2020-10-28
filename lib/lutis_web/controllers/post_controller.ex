defmodule LutisWeb.PostController do
  use LutisWeb, :controller

  alias Lutis.Posts
  alias Lutis.Posts.Post

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Posts.create_post(post_params, conn.assigns.current_user) do
      {:ok, post} ->
        conn
        |> redirect(to: Routes.post_path(conn, :show, Posts.get_author(post), post.url_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post_by_url_id(id)
    if (post == nil or post.author != conn.assigns.current_user) do
      conn |> redirect(to: Routes.live_path(conn, LutisWeb.PostIndexLive))
    else
      changeset = Posts.change_post(post)
      render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post_by_url_id(id)
    if (post == nil or post.author != conn.assigns.current_user) do
      conn |> redirect(to: Routes.live_path(conn, LutisWeb.PostIndexLive))
    else
      case Posts.update_post(post, post_params) do
        {:ok, post} ->
          conn
          |> redirect(to: Routes.post_path(conn, :show, Posts.get_author(post), post.url_id))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", post: post, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post_by_url_id(id)
    if (post == nil or post.author != conn.assigns.current_user) do
      conn |> redirect(to: Routes.live_path(conn, LutisWeb.PostIndexLive))
    else
      {:ok, _post} = Posts.delete_post(post)

      conn
      |> put_flash(:info, "Post deleted successfully.")
      |> redirect(to: Routes.live_path(conn, LutisWeb.PostIndexLive))
    end
  end

  def show(conn, %{"id" => id}) do
    post = Posts.get_post_by_url_id(id)
    if(post == nil) do
      conn |> redirect(to: Routes.live_path(conn, LutisWeb.PostIndexLive))
    else
      Posts.add_view(post)
      live_render(conn, LutisWeb.PostLive, session: %{"post_id" => id})
    end
  end
end
