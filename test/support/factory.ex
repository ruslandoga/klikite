defmodule K.Factory do
  use ExMachina.Ecto, repo: K.Repo

  alias K.Website

  def website_factory do
    %Website{name: "my blog", domain: "copycat.fun"}
  end
end
