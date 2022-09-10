defmodule K.Ingester do
  @moduledoc """
  Contains functions to ingests browser events, process them into pageviews and sessions.
  """
  alias K.{Repo, Session, Event, Pageview}
  import Ecto.Query

  # @pubsub K.PubSub
  # @events_topic "events"

  # @doc """
  # Subscribes for `{#{__MODULE__}, :events}` messages that indicate new events.
  # """
  # def events_subscribe do
  #   Phoenix.PubSub.subscribe(@pubsub, @events_topic)
  # end

  # TODO
  # - very naive insert for now, will be optimised later.
  def insert_heartbeats(heartbeats) do
    # TODO group by session_id? then insert/upsert together
    # TODO maybe skip session optimisation and instead construct it based at read time
    # {:ok, :ok} =
    #   Repo.transaction(fn ->
    #     events = cast_events(events)
    #     Repo.insert_all(Event, events)
    #     Enum.each(events, &maybe_upsert_session(&1))
    #   end)

    {:ok, _} =
      Repo.transaction(fn ->
        heartbeats = Enum.map(heartbeats, &enhance_heartbeat/1)
        Repo.insert_all("heartbeats", heartbeats)
      end)

    :ok

    # :ok = Phoenix.PubSub.broadcast!(@pubsub, @events_topic, {__MODULE__, :events})
  end

  def enhance_heartbeat(heartbeat) do
    # TODO
    time = :os.system_time(:millisecond) / 1000

    %{
      user_agent: user_agent,
      ip: ip,
      referer: referer,
      domain: domain,
      url: url,
      language: language,
      width: width
    } = heartbeat

    IO.inspect(heartbeat, label: "heartbeat.1")

    %UAParser.UA{family: browser, os: %UAParser.OperatingSystem{family: os}} =
      UAParser.parse(user_agent)

    {country, city} =
      case :locus.lookup(:city, ip) do
        {:ok, %{"country" => %{"iso_code" => country}, "city" => %{"names" => %{"en" => city}}}} ->
          # or geoname id?
          {country, city}

        :not_found ->
          {nil, nil}
      end

    heartbeat = [
      time: time,
      hash: hash(domain, ip, user_agent),
      url: url,
      domain: domain,
      referer: referer,
      os: os,
      browser: browser,
      device: get_device(os, width),
      country: country,
      city: city,
      language: language
    ]

    IO.inspect(heartbeat, label: "heartbeat.2")
  end

  def hash(domain, ip, user_agent) do
    # TODO siphash
    :crypto.hash(:sha256, [domain, ip, user_agent, salt()])
  end

  defp salt do
    # TODO rotate
    "salt"
  end

  # defp maybe_upsert_session(%{time: time} = event) do
  #   prev_session_id = prev_session_id() || 0
  #   prev_event = prev_event(time)
  #   # 30 minutes in seconds
  #   interval = 30 * 60

  #   within_interval? =
  #     if prev_event do
  #       diff = time - prev_event.time

  #       if diff < interval do
  #         last_session_rowid =
  #           Session
  #           |> order_by(desc: :rowid)
  #           |> limit(1)
  #           |> select([s], s.rowid)

  #         Session
  #         |> where([s], s.rowid == subquery(last_session_rowid))
  #         |> Repo.update_all(inc: [length: diff])
  #       end
  #     end

  #   # TODO don't need?
  #   if within_interval? do
  #     unless Map.take(event, [:website_id, :hostname, :ip, :user_agent]) ==
  #              Map.take(prev_event, [:website_id, :hostname, :ip, :user_agent]) do
  #       new_session_id = if within_interval?, do: prev_session_id, else: prev_session_id + 1

  #       new_session = %{
  #         id: new_session_id,
  #         start: time,
  #         length: 0,
  #         website_id: event.website_id,
  #         hostname: event.hostname,
  #         ip: event.ip
  #       }

  #       Repo.insert_all(Session, [new_session])
  #     end
  #   else
  #     new_session_id = if within_interval?, do: prev_session_id, else: prev_session_id + 1

  #     new_session = %{
  #       id: new_session_id,
  #       start: time,
  #       length: 0,
  #       website_id: event.website_id,
  #       hostname: event.hostname,
  #       ip: event.ip
  #     }

  #     Repo.insert_all(Session, [new_session])
  #   end
  # end

  # def session_hash(website_id, domain, ip, user_agent) do
  #   # TODO siphash
  #   :crypto.hash(:sha256, [to_string(website_id), domain, ip, user_agent, session_salt()])
  # end

  # def session_salt do
  #   # TODO rotating salt?
  #   "salt"
  # end

  # defp prev_event(time) do
  #   Event
  #   |> limit(1)
  #   |> order_by(desc: :time)
  #   |> where([h], h.time < ^time)
  #   |> select([h], map(h, [:website_id, :hostname, :ip, :user_agent]))
  #   |> Repo.one()
  # end

  # defp prev_session_id do
  #   Session
  #   |> order_by(desc: :id)
  #   |> limit(1)
  #   |> select([d], d.id)
  #   |> Repo.one()
  # end

  # @doc false
  # def cast_events(events) do
  #   Enum.map(events, &prepare_event/1)
  # end

  # defp prepare_event(%{user_agent: user_agent, domain: domain} = event) do
  #   os = String.replace(os, ["(", ")"], "")

  #   event
  #   |> Map.delete("user_agent")
  #   |> Map.put("editor", editor)
  #   |> Map.put("operating_system", os)
  #   |> Map.update("is_write", nil, fn is_write -> !!is_write end)
  #   |> cast_event()
  #   |> Map.take(Event.__schema__(:fields))
  # end

  # defp cast_event(data) do
  #   import Ecto.Changeset

  #   %Event{}
  #   |> cast(data, Event.__schema__(:fields))
  #   |> apply_action!(:insert)
  # end

  @desktop_screen_width 1920
  @laptop_screen_width 1024
  @mobile_screen_width 479

  @desktop_os [
    "Windows 3.11",
    "Windows 95",
    "Windows 98",
    "Windows 2000",
    "Windows XP",
    "Windows Server 2003",
    "Windows Vista",
    "Windows 7",
    "Windows 8",
    "Windows 8.1",
    "Windows 10",
    "Windows ME",
    "Open BSD",
    "Sun OS",
    "Linux",
    "Mac OS",
    "QNX",
    "BeOS",
    "OS/2",
    "Chrome OS"
  ]

  @mobile_os ["iOS", "Android OS", "BlackBerry OS", "Windows Mobile", "Amazon OS"]

  @doc """
  Gets the device type based on screen resolution and OS.

  Example:

      iex> get_device("1920x1080", "Chrome OS")
      "laptop"

      iex> get_device("1920x1080", "Mac OS")
      "laptop"

  """
  def get_device(os, width) do
    # [width, _height] = String.split(screen, "x")
    _device(os, width)
  end

  # TODO
  defp _device("Chrome OS", _width), do: "laptop"

  defp _device(os, width) when os in @desktop_os and width < @desktop_screen_width do
    "laptop"
  end

  defp _device(os, _width) when os in @desktop_os, do: "desktop"

  # TODO
  defp _device("Amazon OS", _width), do: "tablet"

  defp _device(os, width) when os in @mobile_os and width > @mobile_screen_width do
    "tablet"
  end

  defp _device(os, _width) when os in @mobile_os, do: "mobile"
  defp _device(_os, width) when width >= @desktop_screen_width, do: "desktop"
  defp _device(_os, width) when width >= @laptop_screen_width, do: "laptop"
  defp _device(_os, width) when width >= @mobile_screen_width, do: "tablet"
  defp _device(_os, _width), do: "mobile"

  @doc """
  Gets the country ISO code based on IP address.

  Example:

      iex> get_country("37.232.45.178")
      "GE"

  """
  def get_country(ip) when is_binary(ip) do
    case K.Location.location_from_ip(ip) do
      %{"country" => %{"iso_code" => iso_code}} -> iso_code
      _other -> nil
    end
  end

  @doc """
  Collects client info based on user agent header, ip address, and screen size.

  Example:

      iex> user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15"
      iex> ip = "37.232.45.178"
      iex> screen = "1920x1080"
      iex> get_client_info(user_agent, ip, screen)
      %{browser: "Safari", country: "GE", device: "desktop", os: "Mac OS X"}

  """
  def get_client_info(user_agent, ip, screen) do
    # TODO https://github.com/matomo-org/device-detector
    # https://github.com/DamonOehlman/detect-browser/blob/master/src/index.ts
    %UAParser.UA{family: browser, os: %UAParser.OperatingSystem{family: os}} =
      UAParser.parse(user_agent)

    %{browser: browser, os: os, country: get_country(ip), device: get_device(screen, os)}
  end
end
