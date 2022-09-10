defmodule K.Factory do
  use ExMachina.Ecto, repo: K.Repo

  alias K.Accounts.Website

  def website_factory do
    %Website{name: "my blog", domain: "copycat.fun"}
  end

  # TODO
  def build_event(overrides \\ []) do
    event = %{
      id: Ecto.Flake.bingenerate(),
      # from js
      name: "pageview",
      url: "https://copycat.fun/wakatime/",
      domain: "copycat.fun",
      referer: "https://copycat.fun/",
      w: 1324,
      # from tcp/ip
      ip: "37.232.45.178",
      # from headers
      origin: "https://copycat.fun",
      referer_h: "https://copycat.fun/",
      user_agent:
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15"
    }

    overrides = overrides |> Map.new() |> Map.take(Map.keys(event))
    Map.merge(event, overrides)
  end
end
