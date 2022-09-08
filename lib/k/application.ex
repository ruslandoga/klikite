defmodule K.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @app :k
  use Application

  @impl true
  def start(_type, _args) do
    repo_config = Application.fetch_env!(@app, K.Repo)

    children = [
      # Start the Ecto repository
      K.Repo,
      {K.Release.Migrator, migrate: repo_config[:migrate]},
      # Start the Telemetry supervisor
      KWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: K.PubSub},
      # Start the Endpoint (http/https)
      KWeb.Endpoint
      # Start a worker by calling: K.Worker.start_link(arg)
      # {K.Worker, arg}
    ]

    # TODO wait with :locus.await_loader(@db) before readiness_notifier
    maybe_setup_locus()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: K.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp maybe_setup_locus do
    if key = Application.get_env(@app, :maxmind_license_key) do
      K.Location.setup(key)
    end
  end
end
