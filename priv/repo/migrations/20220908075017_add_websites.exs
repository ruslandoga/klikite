defmodule K.Repo.Migrations.AddWebsites do
  use Ecto.Migration

  def change do
    create table(:websites) do
      add :name, :text, null: false
      add :domain, :text
      timestamps()
    end

    create unique_index(:websites, [:domain])
  end
end
