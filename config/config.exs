# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :k,
  ecto_repos: [K.Repo]

# Configures the endpoint
config :k, KWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: KWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: K.PubSub,
  live_view: [signing_salt: "J1m96N76"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :sentry, client: K.Extensions.Sentry.FinchClient

config :sentry,
  enable_source_code_context: true,
  root_source_code_paths: [File.cwd!()]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
