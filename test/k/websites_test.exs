defmodule K.WebsitesTest do
  use K.DataCase
  alias K.Website

  def changeset(website, attrs) do
    website
    |> cast(attrs, [:name, :domain])
    |> update_change(:domain, fn domain -> domain |> String.trim() |> String.downcase() end)
    |> validate_required([:name, :domain])
    |> validate_change(:domain, fn :domain, domain -> validate_domain(domain) end)
    |> unique_constraint(:domain)
  end

  # TODO
  defp validate_domain(_domain), do: []

  def find_website(domain) do
    Repo.get_by(Website, domain: domain)
  end

  test "create website" do
    assert {:ok, %Website{} = copycat} =
             %Website{}
             |> changeset(%{"name" => "my blog", "domain" => "copycat.fun"})
             |> Repo.insert()

    assert {:ok, %Website{} = stats} =
             %Website{}
             |> changeset(%{"name" => "my stats", "domain" => "stats.copycat.fun"})
             |> Repo.insert()

    assert copycat.domain == "copycat.fun"
    assert copycat.name == "my blog"

    assert stats.domain == "stats.copycat.fun"
    assert stats.name == "my stats"

    assert stats.id > copycat.id

    assert %Website{name: "my blog", domain: "copycat.fun"} = find_website("copycat.fun")

    assert %Website{name: "my stats", domain: "stats.copycat.fun"} =
             find_website("stats.copycat.fun")
  end
end
