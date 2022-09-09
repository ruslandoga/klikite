defmodule K.Event do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, Ecto.Flake, autogenerate: true}
  schema "events" do
    field :website_id, :integer
    field :session_id, :binary
    field :url, :string
    field :event_type, :string
    field :event_value, :string
  end
end
