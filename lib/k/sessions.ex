defmodule K.Sessions do
  @moduledoc """
  Contains functions to aggregate sessions
  """
  use GenServer

  # TODO tab per scheduler
  # TODO cleanup strategy, how should it work? timers? full-scan? generations?

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @impl true
  def init(opts) do
    # write/read concurrency, bench
    :ets.new(opts[:tab] || __MODULE__, [:named_table])
    {:ok, opts}
  end

  # def prolong_session(tab \\ __MODULE__, event) do
  #   %{domain: domain, hostname: hostname, ip: ip, user_agent: user_agent} = event
  #   website_id = lookup_website_id(domain)
  #   session_id = session_id(website_id, hostname, ip, user_agent)

  #   case :ets.lookup(tab, session_id) do
  #     [] ->
  #       flake = Ecto.Flake.bingenerate()
  #       :ets.insert(tab, {session_id, flake})
  #       # :ets.insert(tab, {flake, session_id})
  #   end
  # end

  def session_id(website_id, hostname, ip, user_agent) do
    :crypto.hash(:sha256, [to_string(website_id), hostname, ip, user_agent, salt()])
  end

  def salt do
    # TODO
    "salt"
  end
end
