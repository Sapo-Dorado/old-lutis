defmodule Lutis.Messaging do
  import Ecto.Query, warn: false
  alias Lutis.Repo

  alias Lutis.Messaging.{Thread,Message}

  #Thread Functions
  def list_threads(user_id) do
    Ecto.Query.from(t in Thread, where: t.user1 == ^user_id or t.user2 == ^user_id)
    |> Repo.all
  end

  def get_thread(user_id, recipient_id) do
    query = (cond do
              user_id < recipient_id ->
                Ecto.Query.from(t in Thread, where: t.user1 == ^user_id and t.user2 == ^recipient_id)
              true ->
                Ecto.Query.from(t in Thread, where: t.user1 == ^recipient_id and t.user2 == ^user_id)
            end)
    Repo.one(query)
  end

  def create_thread(attrs \\ %{}) do
    case get_thread(attrs["user_id"], attrs["recipient_id"]) do
      nil ->
        thread_attrs = (cond do
                          attrs["user_id"] < attrs["recipient_id"] ->
                            attrs
                            |> Map.put("user1", attrs["user_id"])
                            |> Map.put("user2", attrs["recipient_id"])
                          true ->
                            attrs
                            |> Map.put("user1", attrs["user_id"])
                            |> Map.put("user2", attrs["recipient_id"])
                        end)
        %Thread{}
        |> Thread.changeset(thread_attrs)
        |> Repo.insert()
      thread ->
        {:ok, thread}
    end
  end

  def change_thread(%Thread{} = thread, attrs \\ %{}) do
    Thread.changeset(thread, attrs)
  end

  def delete_thread(%Thread{} = thread) do
    Repo.delete(thread)
  end

  #Message Functions
  def list_messages(thread) do
    Repo.preload(thread, :messages).messages
  end

  def get_message!(id), do: Repo.get!(Message, id)

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(Map.put(attrs, "time_sent", NaiveDateTime.utc_now))
    |> Repo.insert()
  end

  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
