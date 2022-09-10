defmodule K.Repo.Migrations.AddHeartbeats do
  use Ecto.Migration

  def change do
    create table(:heartbeats, primary_key: false, options: "WITHOUT ROWID") do
      add :time, :real, primary_key: true, null: false
      add :hash, :binary, null: false

      add :url, :text, null: false
      add :domain, :text, null: false
      add :referer, :text

      # add :type, :text

      add :os, :text
      add :browser, :text
      add :device, :text

      add :country, :text
      add :city, :text

      add :language, :text
    end
  end
end
