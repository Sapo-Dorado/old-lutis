defmodule LutisWeb.PostController do
  use LutisWeb, :controller

  alias Lutis.Posts
  alias Lutis.Posts.Post
  alias Lutis.Accounts

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Posts.create_post(post_params, conn.assigns.current_user) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, Posts.get_author(post), post.url_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
      post = Posts.get_post_by_url_id(id)
    if (conn.query_string == "") do
      render(conn, "show.html", post: Posts.add_view(post))
    else
      render(conn, "show.html", post: post)
    end
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post_by_url_id(id)
    if !(post.author == conn.assigns.current_user) do
      conn |> redirect(to: Routes.post_path(conn, :index))
    else
      changeset = Posts.change_post(post)
      render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post_by_url_id(id)
    if !(post.author == conn.assigns.current_user) do
      conn |> redirect(to: Routes.post_path(conn, :index))
    else
      case Posts.update_post(post, post_params) do
        {:ok, post} ->
          conn
          |> put_flash(:info, "Post updated successfully.")
          |> redirect(to: Routes.post_path(conn, :show, Posts.get_author(post), post.url_id))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", post: post, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post_by_url_id(id)
    if !(post.author == conn.assigns.current_user) do
      conn |> redirect(to: Routes.post_path(conn, :index))
    else
      {:ok, _post} = Posts.delete_post(post)

      conn
      |> put_flash(:info, "Post deleted successfully.")
      |> redirect(to: Routes.post_path(conn, :index))
    end
  end

  def upvote(conn, %{"id" => id}) do
    post = Posts.get_post_by_url_id(id)
    Posts.create_upvote(post, conn.assigns.current_user)
    conn
    |> redirect(to: "#{Routes.post_path(conn, :show, Posts.get_author(post), id, action: true)}#view")
  end
end
