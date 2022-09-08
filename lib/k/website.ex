defmodule K.Website do
  @moduledoc false
  use Ecto.Schema

  schema "websites" do
    field :name, :string
    field :domain, :string
    timestamps()
  end
end
