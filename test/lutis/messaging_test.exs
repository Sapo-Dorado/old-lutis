defmodule Lutis.MessagingTest do
  use Lutis.DataCase

  alias Lutis.Messaging

  describe "threads" do
    alias Lutis.Messaging.Thread

    @valid_attrs %{user1: "some user1", user2: "some user2"}
    @update_attrs %{user1: "some updated user1", user2: "some updated user2"}
    @invalid_attrs %{user1: nil, user2: nil}

    def thread_fixture(attrs \\ %{}) do
      {:ok, thread} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Messaging.create_thread()

      thread
    end

    test "list_threads/0 returns all threads" do
      thread = thread_fixture()
      assert Messaging.list_threads() == [thread]
    end

    test "get_thread!/1 returns the thread with given id" do
      thread = thread_fixture()
      assert Messaging.get_thread!(thread.id) == thread
    end

    test "create_thread/1 with valid data creates a thread" do
      assert {:ok, %Thread{} = thread} = Messaging.create_thread(@valid_attrs)
      assert thread.user1 == "some user1"
      assert thread.user2 == "some user2"
    end

    test "create_thread/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_thread(@invalid_attrs)
    end

    test "update_thread/2 with valid data updates the thread" do
      thread = thread_fixture()
      assert {:ok, %Thread{} = thread} = Messaging.update_thread(thread, @update_attrs)
      assert thread.user1 == "some updated user1"
      assert thread.user2 == "some updated user2"
    end

    test "update_thread/2 with invalid data returns error changeset" do
      thread = thread_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.update_thread(thread, @invalid_attrs)
      assert thread == Messaging.get_thread!(thread.id)
    end

    test "delete_thread/1 deletes the thread" do
      thread = thread_fixture()
      assert {:ok, %Thread{}} = Messaging.delete_thread(thread)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_thread!(thread.id) end
    end

    test "change_thread/1 returns a thread changeset" do
      thread = thread_fixture()
      assert %Ecto.Changeset{} = Messaging.change_thread(thread)
    end
  end

  describe "messages" do
    alias Lutis.Messaging.Message

    @valid_attrs %{author: "some author", contents: "some contents", time_sent: "2010-04-17T14:00:00Z"}
    @update_attrs %{author: "some updated author", contents: "some updated contents", time_sent: "2011-05-18T15:01:01Z"}
    @invalid_attrs %{author: nil, contents: nil, time_sent: nil}

    def message_fixture(attrs \\ %{}) do
      {:ok, message} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Messaging.create_message()

      message
    end

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Messaging.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Messaging.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      assert {:ok, %Message{} = message} = Messaging.create_message(@valid_attrs)
      assert message.author == "some author"
      assert message.contents == "some contents"
      assert message.time_sent == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, %Message{} = message} = Messaging.update_message(message, @update_attrs)
      assert message.author == "some updated author"
      assert message.contents == "some updated contents"
      assert message.time_sent == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.update_message(message, @invalid_attrs)
      assert message == Messaging.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Messaging.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Messaging.change_message(message)
    end
  end
end
