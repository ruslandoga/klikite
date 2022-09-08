defmodule KWeb.Plugs.HealthCheck do
  @moduledoc false
  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%Plug.Conn{path_info: ["health"]} = conn, _opts) do
    status = if K.Release.ready?(), do: 200, else: 500

    conn
    |> send_resp(status, [])
    |> halt()
  end

  def call(conn, _opts), do: conn
end
