defmodule KWeb.Plugs.ConfigureLoggerMetadata do
  @moduledoc false
  @behaviour Plug
  require Logger

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    Logger.metadata(remote_ip: :inet.ntoa(conn.remote_ip))
    conn
  end
end
