defmodule Lutis.PostsTest do
  use Lutis.DataCase

  alias Lutis.Posts

  describe "posts" do
    alias Lutis.Posts.Post

    @valid_attrs %{author: 42, contents: "some contents", topic: "some topic", upvotes: 42, views: 42}
    @update_attrs %{author: 43, contents: "some updated contents", topic: "some updated topic", upvotes: 43, views: 43}
    @invalid_attrs %{author: nil, contents: nil, topic: nil, upvotes: nil, views: nil}

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Posts.create_post()

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Posts.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Posts.create_post(@valid_attrs)
      assert post.author == 42
      assert post.contents == "some contents"
      assert post.topic == "some topic"
      assert post.upvotes == 42
      assert post.views == 42
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, %Post{} = post} = Posts.update_post(post, @update_attrs)
      assert post.author == 43
      assert post.contents == "some updated contents"
      assert post.topic == "some updated topic"
      assert post.upvotes == 43
      assert post.views == 43
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end

  describe "upvotes" do
    alias Lutis.Posts.Upvote

    @valid_attrs %{time: "2010-04-17T14:00:00Z", user: 42}
    @update_attrs %{time: "2011-05-18T15:01:01Z", user: 43}
    @invalid_attrs %{time: nil, user: nil}

    def upvote_fixture(attrs \\ %{}) do
      {:ok, upvote} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Posts.create_upvote()

      upvote
    end

    test "list_upvotes/0 returns all upvotes" do
      upvote = upvote_fixture()
      assert Posts.list_upvotes() == [upvote]
    end

    test "get_upvote!/1 returns the upvote with given id" do
      upvote = upvote_fixture()
      assert Posts.get_upvote!(upvote.id) == upvote
    end

    test "create_upvote/1 with valid data creates a upvote" do
      assert {:ok, %Upvote{} = upvote} = Posts.create_upvote(@valid_attrs)
      assert upvote.time == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert upvote.user == 42
    end

    test "create_upvote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_upvote(@invalid_attrs)
    end

    test "update_upvote/2 with valid data updates the upvote" do
      upvote = upvote_fixture()
      assert {:ok, %Upvote{} = upvote} = Posts.update_upvote(upvote, @update_attrs)
      assert upvote.time == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert upvote.user == 43
    end

    test "update_upvote/2 with invalid data returns error changeset" do
      upvote = upvote_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_upvote(upvote, @invalid_attrs)
      assert upvote == Posts.get_upvote!(upvote.id)
    end

    test "delete_upvote/1 deletes the upvote" do
      upvote = upvote_fixture()
      assert {:ok, %Upvote{}} = Posts.delete_upvote(upvote)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_upvote!(upvote.id) end
    end

    test "change_upvote/1 returns a upvote changeset" do
      upvote = upvote_fixture()
      assert %Ecto.Changeset{} = Posts.change_upvote(upvote)
    end
  end
end
