defmodule Lutis.Posts do

  import Ecto.Query, warn: false
  alias Lutis.Repo

  alias Lutis.Posts.{Post, Upvote}
  alias Lutis.Accounts

  use Bitwise

  def post_stream(%{"search" => %{"query" => query, "order" => order}}) do
    wildcard_search = "%#{query}%"

    query = from p in Post,
      where: ilike(p.title, ^wildcard_search),
      or_where: ilike(p.topic, ^wildcard_search)

    case order do
      "upvoted" ->
        from(p in query, order_by: [desc: p.upvotes, asc: p.id])
      "recent" ->
        from(p in query, order_by: [desc: p.id])
    end
    |> Repo.stream()
  end

  def post_stream(params) do
    post_stream(%{"search" => %{"query" => nil, "order" => "upvoted"}})
  end

  def get_batch(post_stream, chunk_size) do
    case Repo.transaction(fn() -> Stream.take(post_stream, chunk_size) |> Enum.to_list() end) do
      {:ok, post_list} ->
        case post_list do
          [] -> {:ok, post_list, nil}
          _ ->
            case Repo.transaction(fn() -> Stream.drop(post_stream, chunk_size) end) do
              {:ok, new_stream} ->
                {:ok, post_list, new_stream}
              error -> error
            end
        end
      error -> error
    end
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
    Accounts.verify_user(conn) == post.author
  end

  def get_author(post) do
    case Accounts.get_username(post.author) do
      nil -> "<deleted-author>"
      username -> username
    end
  end

end
