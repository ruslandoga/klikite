defmodule K.Repo.Migrations.AddPageviews do
  use Ecto.Migration

  def change do
    create table(:pageviews, primary_key: false, options: "WITHOUT ROWID") do
      add :id, :binary, primary_key: true, null: false
      add :website_id, references(:websites, on_delete: :delete_all), null: false
      add :session_id, references(:sessions, on_delete: :delete_all), null: false
      add :url, :text, null: false
      add :referrer, :text
    end
  end
end
