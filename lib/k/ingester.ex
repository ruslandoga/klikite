defmodule K.Ingester do
  @moduledoc """
  Contains functions to ingests browser events, process them into pageviews and sessions.
  """
  alias K.{Repo, Session, Event, Pageview}
  import Ecto.Query

  # TODO
  # - very naive insert for now, will be optimised later.
  def insert_events(events) do
    # TODO group by session_id? then insert/upsert together
    # TODO maybe skip session optimisationa nd instead construct it based at read time
    {:ok, :ok} =
      Repo.transaction(fn ->
        events = cast_events(events)
        Repo.insert_all(Event, events)
        Enum.each(events, &maybe_upsert_session(&1))
      end)

    :ok = Phoenix.PubSub.broadcast!(K.PubSub, "events", {__MODULE__, :events})
  end

  defp maybe_upsert_session(%{time: time} = event) do
    prev_session_id = prev_session_id() || 0
    prev_event = prev_event(time)
    # 30 minutes in seconds
    interval = 30 * 60

    within_interval? =
      if prev_event do
        diff = time - prev_event.time

        if diff < interval do
          last_session_rowid =
            Session
            |> order_by(desc: :rowid)
            |> limit(1)
            |> select([s], s.rowid)

          Session
          |> where([s], s.rowid == subquery(last_session_rowid))
          |> Repo.update_all(inc: [length: diff])
        end
      end

    # TODO don't need?
    if within_interval? do
      unless Map.take(event, [:website_id, :hostname, :ip, :user_agent]) ==
               Map.take(prev_event, [:website_id, :hostname, :ip, :user_agent]) do
        new_session_id = if within_interval?, do: prev_session_id, else: prev_session_id + 1

        new_session = %{
          id: new_session_id,
          start: time,
          length: 0,
          website_id: event.website_id,
          hostname: event.hostname,
          ip: event.ip
        }

        Repo.insert_all(Session, [new_session])
      end
    else
      new_session_id = if within_interval?, do: prev_session_id, else: prev_session_id + 1

      new_session = %{
        id: new_session_id,
        start: time,
        length: 0,
        website_id: event.website_id,
        hostname: event.hostname,
        ip: event.ip
      }

      Repo.insert_all(Session, [new_session])
    end
  end

  defp prev_event(time) do
    Event
    |> limit(1)
    |> order_by(desc: :time)
    |> where([h], h.time < ^time)
    |> select([h], map(h, [:website_id, :hostname, :ip, :user_agent]))
    |> Repo.one()
  end

  defp prev_session_id do
    Session
    |> order_by(desc: :id)
    |> limit(1)
    |> select([d], d.id)
    |> Repo.one()
  end

  @doc false
  def cast_events(events) do
    Enum.map(events, &prepare_event/1)
  end

  defp prepare_event(%{"user_agent" => user_agent} = event) do
    ["wakatime/" <> _wakatime_version, os, _python_or_go_version, editor, _extension] =
      String.split(user_agent, " ")

    os = String.replace(os, ["(", ")"], "")

    event
    |> Map.delete("user_agent")
    |> Map.put("editor", editor)
    |> Map.put("operating_system", os)
    |> Map.update("is_write", nil, fn is_write -> !!is_write end)
    |> cast_event()
    |> Map.take(Event.__schema__(:fields))
  end

  defp cast_event(data) do
    import Ecto.Changeset

    %Event{}
    |> cast(data, Event.__schema__(:fields))
    |> apply_action!(:insert)
  end
end
