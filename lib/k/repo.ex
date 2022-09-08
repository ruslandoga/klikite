defmodule K.Repo do
  use Ecto.Repo,
    otp_app: :k,
    adapter: Ecto.Adapters.SQLite3
end
