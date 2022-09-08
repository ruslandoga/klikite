defmodule K.SessionsTest do
  use K.DataCase
  alias K.Session

  setup do
    {:ok, _} = :locus.await_loader(:city)
    :ok
  end

  test "create session" do
    insert(:website)

    event = %{
      n: "pageview",
      u: "https://copycat.fun/wakatime/",
      d: "copycat.fun",
      r: "https://copycat.fun/",
      w: 1324,
      ip: "37.232.45.178",
      origin: "https://copycat.fun",
      referer: "https://copycat.fun/",
      user_agent:
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15"
    }

    %{d: domain, ip: ip, user_agent: user_agent} = event
    assert website = find_website(domain)
    session_id = K.Sessions.session_id(website.id, _hostname = domain, ip, user_agent)

    %Session{
      id: session_id,
      website_id: website.id,
      # hostname: hostname,
      # browser: browser(user_agent),
      # os: os(user_agent),
      # device: device(user_agent),
      # screen: screen(user_agent),
      # language: language,
      country: country(ip)
    }
  end

  def country(ip) do
    %{"country" => %{"iso_code" => iso_code}} = K.Location.location_from_ip(ip)
    iso_code
  end

  test "prolong session"

  # ???
  test "finish session"

  def find_website(domain) do
    Repo.get_by(K.Website, domain: domain)
  end
end
