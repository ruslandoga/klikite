defmodule K.Extensions.Sentry.FinchClient do
  @moduledoc false
  @behaviour Sentry.HTTPClient

  @impl true
  def child_spec do
    child_spec = {Finch, name: __MODULE__, pools: %{default: [protocol: :http2]}}
    Supervisor.child_spec(child_spec, [])
  end

  @impl true
  def post(url, headers, body) do
    req = Finch.build(:post, url, headers, body)

    case Finch.request(req, __MODULE__, receive_timeout: 5000) do
      {:ok, %Finch.Response{status: status, body: body, headers: headers}} ->
        {:ok, status, headers, body}

      {:error, _reason} = failure ->
        failure
    end
  end
end
