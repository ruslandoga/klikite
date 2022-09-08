defmodule KWeb.EventController do
  use KWeb, :controller

  def create(conn, params) do
    event = build_event(conn, params)
    K.Ingester.ingest_event(event)
    send_resp(conn, 201, [])
  end

  def build_event(conn, params) do
    %{"n" => n, "u" => u, "d" => d, "r" => r, "w" => w} = params
    ip = to_string(:inet.ntoa(conn.remote_ip))
    event = %{n: n, u: u, d: d, r: r, w: w, ip: ip}
    from_headers(conn.req_headers, event)
  end

  defp from_headers([{"origin", origin} | headers], acc) do
    from_headers(headers, Map.put(acc, :origin, origin))
  end

  defp from_headers([{"referer", referer} | headers], acc) do
    from_headers(headers, Map.put(acc, :referer, referer))
  end

  defp from_headers([{"user-agent", user_agent} | headers], acc) do
    from_headers(headers, Map.put(acc, :user_agent, user_agent))
  end

  defp from_headers([_header | headers], acc) do
    from_headers(headers, acc)
  end

  defp from_headers([], acc), do: acc
end

# curl 'https://who.copycat.fun/api/event' \
# -X 'POST' \
# -H 'Accept: */*' \
# -H 'Content-Type: text/plain' \
# -H 'Origin: https://copycat.fun' \
# -H 'Referer: https://copycat.fun/' \
# -H 'Content-Length: 79' \
# -H 'Accept-Language: en-GB,en;q=0.9' \
# -H 'Host: who.copycat.fun' \
# -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15' \
# -H 'Accept-Encoding: gzip, deflate, br' \
# -H 'Connection: keep-alive' \
# -H 'Priority: u=3, i' \
# --data-binary '{"n":"pageview","u":"https://copycat.fun/","d":"copycat.fun","r":null,"w":1324}'

# curl 'https://who.copycat.fun/api/event' \
# -X 'POST' \
# -H 'Accept: */*' \
# -H 'Content-Type: text/plain' \
# -H 'Origin: https://copycat.fun' \
# -H 'Referer: https://copycat.fun/' \
# -H 'Content-Length: 106' \
# -H 'Accept-Language: en-GB,en;q=0.9' \
# -H 'Host: who.copycat.fun' \
# -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15' \
# -H 'Accept-Encoding: gzip, deflate, br' \
# -H 'Connection: keep-alive' \
# -H 'Priority: u=3, i' \
# --data-binary '{"n":"pageview","u":"https://copycat.fun/wakatime/","d":"copycat.fun","r":"https://copycat.fun/","w":1324}'
