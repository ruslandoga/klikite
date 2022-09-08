defmodule K.Repo.Migrations.AddSessions do
  use Ecto.Migration

  def change do
    create table(:sessions, primary_key: false, options: "WITHOUT ROWID") do
      add :id, :binary, primary_key: true, null: false
      add :website_id, references(:websites, on_delete: :delete_all), null: false
      add :hostname, :text
      add :browser, :text
      add :os, :text
      add :device, :text
      add :screen, :text
      add :language, :text
      add :country, :text
    end
  end
end
