defmodule K.Session do
  @moduledoc false
  use Ecto.Schema

  @primary_key false
  schema "sessions" do
    field :id, :binary, primary_key: true
    field :website_id, :integer
    field :hostname, :string
    field :browser, :string
    field :os, :string
    field :device, :string
    field :screen, :string
    field :language, :string
    field :country, :string
  end
end
