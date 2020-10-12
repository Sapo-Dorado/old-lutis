defmodule Lutis.Posts do

  import Ecto.Query, warn: false
  alias Lutis.Repo

  alias Lutis.Posts.{Post, Upvote}

  use Bitwise

  def list_posts(%{"query" => query, "order" => order}) do
    wildcard_search = "%#{query}%"

    query = from p in Post,
      where: ilike(p.title, ^wildcard_search),
      or_where: ilike(p.topic, ^wildcard_search)

    case order do
      "upvoted" ->
        from(p in query, order_by: [desc: p.upvotes, asc: p.id])
        |> Repo.all()
      "recent" ->
        from(p in query, order_by: [desc: p.id])
        |> Repo.all()
    end
  end

  def list_posts(_params) do
    Repo.all(Post)
  end

  def get_post!(id), do: Repo.get!(Post, id)

  def get_post_by_url_id(url_id) do
    from(p in Post, where: p.url_id == ^url_id)
    |> Repo.one()
  end

  def generate_url_id(post_id) do
    ((post_id + 7) * 719) ^^^ 13669
  end

  def create_post(attrs, user_id) do
    post_attrs = attrs
                 |> Map.put("author", user_id)
    case %Post{} |> Post.changeset(post_attrs) |> Repo.insert() do
      {:ok, post} ->
        post 
        |> Post.changeset(%{"url_id" => generate_url_id(post.id)})
        |> Repo.update()
      error -> error
    end
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def add_view(%Post{} = post) do
    {1, [%Post{views: views}]} = 
      from(p in Post, where: p.id == ^post.id, select: [:views])
      |> Repo.update_all(inc: [views: 1])
    put_in(post.views, views)
  end

  def count_upvotes(post) do
    from(u in Upvote, where: u.post_id == ^post.id)
    |> Repo.aggregate(:count)
  end

  def has_upvoted?(user_id, post) do
    (from(u in Upvote, where: u.post_id == ^post.id, where: u.user == ^user_id) |> Repo.one()) != nil
  end

  def create_upvote(post, user_id) do
    if !has_upvoted?(user_id, post) do
      attrs = %{"time" => NaiveDateTime.utc_now, "user" => user_id, "post_id" => post.id}
      %Upvote{}
      |> Upvote.changeset(attrs)
      |> Repo.insert()
    else
      from(u in Upvote, where: u.post_id == ^post.id, where: u.user == ^user_id)
      |> Repo.one()
      |> Repo.delete()
    end
    post
    |> Post.upvoteChangeset(%{upvotes: count_upvotes(post)})
    |> Repo.update()
  end

  def check_author(conn, post) do
    conn.assigns.current_user == post.author
  end
end
