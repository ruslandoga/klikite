defmodule K.Pageview do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, Ecto.Flake, autogenerate: true}
  schema "pageviews" do
    field :website_id, :integer
    field :session_id, :binary
    field :url, :string
    field :referrer, :string
  end
end
