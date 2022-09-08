defmodule K.Release do
  @moduledoc false
  require Logger

  defmodule Migrator do
    use GenServer

    def start_link(opts) do
      GenServer.start_link(__MODULE__, opts)
    end

    def init(opts) do
      if opts[:migrate], do: K.Release.migrate()
      :ignore
    end
  end

  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  @app :k
  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end

  sha =
    if sha = System.get_env("GIT_SHA") do
      sha
    else
      {sha, 0} = System.cmd("git", ["rev-parse", "HEAD"])
      sha
    end

  def git_sha do
    unquote(String.trim(sha))
  end
end
