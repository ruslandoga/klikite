defmodule K.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :k

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

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  # def rollback(repo, version) do
  #   load_app()
  #   {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  # end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  def ready? do
    # TODO
    true
  end
end
