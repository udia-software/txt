defmodule U0txt.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts U0txt.Endpoint.init([])

  test "it returns 200 for /" do
    # Create a test connection
    conn = conn(:get, "/")

    # Invoke the plug
    conn = U0txt.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.state == :sent
    assert conn.status == 200

    assert conn.resp_body ==
             "<!DOCTYPE HTML>\n<html lang=\"en\">\n<head><title>u0txt</title>\n<meta name=\"description\" content=\"u0txt: ommand line pastebin\"/></head>\n<body><pre>            txt.udia.ca\nNAME:\n  u0txt: command line pastebin.\n\nUSAGE:\n  &lt;cmd&gt; | curl -F 'txt=&lt;-' https://txt.udia.ca\n  or upload from web:\n<form action=\"/\" method=\"POST\"><input name=\"web\" type=\"hidden\" value=\"true\">\n<textarea name=\"txt\" cols=\"60\" rows=\"20\"></textarea>\n<br><input type=\"submit\" value=\"Submit\" /></form>\n\nDESCRIPTION\n  I wanted to write my own text pastebin using Elixir/Erlang and Mnesia.\n\nEXAMPLES\n  ~$ cat yourfile | curl -F 'txt=<-' https://txt.udia.ca\n  https://txt.udia.ca/MOJV\n  ~$ firefox https://txt.udia.ca/MOJV\n\n  Add this to your .*rc file:\n\n  alias txt=\"\\\n    sed -r 's/\\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' \\\n    | curl -F 'txt=<-' https://txt.udia.ca\"\n\n  Now you can pipe directly into txt! Sed removes colours.\n\nSOURCE CODE\n  https://github.com/udia-software/txt\n\nSEE ALSO\n  https://txt.t0.vc/\n</pre></body></html>"
  end

  test "it handles bad posts" do
    conn = conn(:post, "/", "badpost")
    conn = U0txt.Endpoint.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 400
    assert conn.resp_body == "INVALID REQUEST"
  end

  test "it pastebins good posts" do
    conn = conn(:post, "/", %{txt: "hellothere"})
    conn = U0txt.Endpoint.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200

    path =
      conn.resp_body
      |> String.replace("\n", "")
      |> String.replace("https://txt.udia.ca", "")

    conn = conn(:get, path)
    conn = U0txt.Endpoint.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "hellothere"
  end

  test "it returns 404 when no route matches" do
    conn = conn(:get, "/fail")
    conn = U0txt.Endpoint.call(conn, @opts)

    assert conn.status == 404
  end
end
