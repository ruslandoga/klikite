defmodule K.SessionsTest do
  use K.DataCase
  alias K.Session

  setup do
    {:ok, _} = :locus.await_loader(:city)
    :ok
  end

  test "create session" do
    insert(:website)

    :ok = K.Ingester.insert_events([build_event()])
    :ok = K.Ingester.insert_events([build_event()])

    assert Repo.all(Event) == [:asdf]
  end
end
