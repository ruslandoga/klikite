defmodule KWeb.IngestController do
  use KWeb, :controller

  def heartbeat(conn, params) do
    heartbeat = build_heartbeat(conn, params)
    :ok = K.Ingester.insert_heartbeats([heartbeat])
    send_resp(conn, :ok, [])
  end

  def build_heartbeat(conn, params) do
    %Plug.Conn{remote_ip: remote_ip, req_headers: headers} = conn
    IO.inspect(conn)
    %{"d" => domain, "r" => referer, "u" => url, "w" => width} = params

    %{
      domain: domain,
      referer: referer,
      url: url,
      width: width,
      ip: to_string(:inet.ntoa(remote_ip)),
      user_agent: header!(headers, "user-agent"),
      language: headers |> header!("accept-language") |> extract_language()
    }
  end

  @compile {:inline, header!: 2}
  defp header!(headers, name) do
    :proplists.get_value(name, headers) || raise("missing #{name} header")
  end

  # lang_splitter = :binary.compile_pattern([",", "-"])

  def extract_language(accept_language) do
    # [lang, _] = :binary.split(accept_language, lang_splitter)
    [lang, _] = :binary.split(accept_language, [",", "-"])
    lang
  end
end
