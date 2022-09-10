defmodule K.Session do
  @moduledoc false
  use Ecto.Schema

  @primary_key false
  schema "sessions" do
    field :id, :binary, primary_key: true
    field :hash, :binary
    field :website_id, :integer
    field :duration, :integer
    field :domain, :string
    field :browser, :string
    field :os, :string
    field :device, :string
    field :screen, :string
    field :language, :string
    field :country, :string
    field :city, :string
  end
end
