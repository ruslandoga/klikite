defmodule K.Location do
  @moduledoc false
  require Logger
  @db :city

  def setup(key) do
    :ok = Application.put_env(:locus, :license_key, key)
    :ok = :locus.start_loader(@db, {:maxmind, "GeoLite2-City"})
  end

  def location_from_ip(ip_address) do
    case :locus.lookup(@db, ip_address) do
      {:ok, location} ->
        location

      :not_found ->
        Logger.error("couldn't find location for ip address #{inspect(ip_address)}")
        nil
    end
  end
end
