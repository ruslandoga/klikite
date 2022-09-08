defmodule KWeb.Router do
  use KWeb, :router
  import KWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {KWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/", KWeb do
    pipe_through :api

    post "/event", EventController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", KWeb do
  #   pipe_through :api
  # end

  import Phoenix.LiveDashboard.Router

  scope "/" do
    pipe_through [:browser, :dashboard_auth]
    live_dashboard "/telemetry", metrics: KWeb.Telemetry
  end
end
