defmodule Lutis.Messaging do
  import Ecto.Query, warn: false
  alias Lutis.Repo

  alias Lutis.Messaging.{Thread,Message}

  #Thread Functions
  def list_threads(user_id) do
    Ecto.Query.from(t in Thread, where: t.user1 == ^user_id or t.user2 == ^user_id, order_by: [desc: t.lastmessage])
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
                            |> Map.put("user2", attrs["user_id"])
                            |> Map.put("user1", attrs["recipient_id"])
                        end)
        %Thread{}
        |> Thread.changeset(thread_attrs)
        |> Repo.insert()
      thread ->
        {:exists, thread}
    end
  end

  def change_thread(%Thread{} = thread, attrs \\ %{}) do
    Thread.changeset(thread, attrs)
  end

  def delete_thread(%Thread{} = thread) do
    Repo.delete(thread)
  end

  #Message Functions
  def message_stream(thread) do
    Ecto.Query.from(m in Message, where: m.thread_id == ^thread.id, order_by: [desc: m.id])
    |> Repo.stream()
  end

  def get_batch(message_stream, chunk_size) do
    case Repo.transaction(fn() -> message_stream |> Stream.take(chunk_size) |> Enum.reverse() end) do
      {:ok, message_list} ->
        case message_list do
          [] -> {:ok, message_list, nil}
          _  ->
            case Repo.transaction(fn() -> message_stream |> Stream.drop(chunk_size) end) do
              {:ok, new_stream} ->
                case Repo.transaction(fn() -> new_stream |> Stream.take(1) |> Enum.to_list() end) do
                  {:ok, []} ->
                    {:ok, message_list, nil}
                  {:ok, _} ->
                    {:ok, message_list, new_stream}
                  error -> error
                end
              error -> error
            end
        end
      error -> error
    end
  end
  

  def get_message!(id), do: Repo.get!(Message, id)

  def create_message(thread, attrs) do
    currentTime = NaiveDateTime.utc_now
    thread
    |> Thread.changeset(%{lastmessage: currentTime})
    |> Repo.update()
    %Message{}
    |> Message.changeset(Map.put(attrs, "time_sent", currentTime))
    |> Repo.insert()
  end

  def mark_as_read(thread, user) do
    currentTime = NaiveDateTime.utc_now
    if(thread.user1 == user) do 
      thread |> Thread.changeset(%{user1read: currentTime}) |> Repo.update()
    end
    if(thread.user2 == user) do
      thread |> Thread.changeset(%{user2read: currentTime}) |> Repo.update()
    end
  end

  def has_unread_message?(thread, user) do
    cond do
      thread.user1 == user -> thread.user1read < thread.lastmessage
      thread.user2 == user -> thread.user2read < thread.lastmessage
    end
  end

  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end
end
