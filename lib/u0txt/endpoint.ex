defmodule U0txt.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info, matching routes, and dispatching responses.
  """
  @idlen 4
  @key "txt"
  @url Application.get_env(:u0txt, :url)

  @desc "            txt.udia.ca
NAME:
  u0txt: command line pastebin.

USAGE:
  &lt;cmd&gt; | curl -F '#{@key}=&lt;-' #{@url}
  or upload from web:
<form action=\"/\" method=\"POST\" accept-charset=\"UTF-8\"><input name=\"web\" type=\"hidden\" value=\"true\">
<textarea name=\"#{@key}\" cols=\"60\" rows=\"20\"></textarea>
<br><input type=\"submit\" value=\"Submit\" /></form>

DESCRIPTION
  I wanted to write my own text pastebin using Elixir/Erlang and Mnesia.

EXAMPLES
  ~$ cat yourfile | curl -F '#{@key}=<-' #{@url}
  #{@url}/MOJV
  ~$ firefox #{@url}/MOJV

  Add this to your .*rc file:

  alias txt=\"\\
    sed -r 's/\\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' \\
    | curl -F 'txt=<-' #{@url}\"

  Now you can pipe directly into txt! Sed removes colours.

SOURCE CODE
  https://github.com/udia-software/txt

SEE ALSO
  https://txt.t0.vc/
"
  @home "<!DOCTYPE HTML>
<html lang=\"en\">
<head><title>u0txt</title>
<meta name=\"description\" content=\"u0txt: command line pastebin\"/></head>
<body><pre>#{@desc}</pre></body></html>"

  use Plug.Router

  # Log request info, parse form body data, match routes, dispatch functions
  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:urlencoded, :multipart])
  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, @home)
  end

  post "/" do
    case Map.fetch(conn.body_params, @key) do
      {:ok, txt} ->
        id =
          :crypto.strong_rand_bytes(@idlen)
          |> Base.url_encode64()
          |> binary_part(0, @idlen)

        :mnesia.transaction(fn -> :mnesia.write({:txt, id, txt}) end)

        case Map.fetch(conn.body_params, "web") do
          {:ok, "true"} ->
            conn
            |> put_resp_header("Location", "#{@url}/#{id}")
            |> send_resp(302, "#{@url}/#{id}")

          _ ->
            send_resp(conn, 200, "#{@url}/#{id}\n")
        end

      :error ->
        send_resp(conn, 400, "INVALID REQUEST")
    end
  end

  get "/:id" do
    {:atomic, set} = :mnesia.transaction(fn -> :mnesia.read(:txt, id) end)

    case set do
      [{:txt, ^id, body}] ->
        conn
        |> put_resp_header("content-type", "text/plain; charset=utf-8")
        |> send_resp(200, body)

      _ ->
        send_resp(conn, 404, "NOT FOUND")
    end
  end

  match _ do
    send_resp(conn, 404, "NOT FOUND")
  end
end
