defmodule KWeb.UserAuth do
  @moduledoc false

  def dashboard_auth(conn, _opts) do
    dashboard_auth_opts = Application.fetch_env!(:k, :dashboard)
    Plug.BasicAuth.basic_auth(conn, dashboard_auth_opts)
  end
end
