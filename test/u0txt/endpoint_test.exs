defmodule U0txt.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts U0txt.Endpoint.init([])

  test "it returns pong" do
    # Create a test connection
    conn = conn(:get, "/ping")

    # Invoke the plug
    conn = U0txt.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "pong!"
  end

  test "it returns 200 for hello world" do
    # Create a test connection
    conn = conn(:get, "/")

    # Invoke the plug
    conn = U0txt.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Hello, world!"
  end

  test "it returns 404 when no route matches" do
    # Create a test connection
    conn = conn(:get, "/fail")

    # Invoke the plug
    conn = U0txt.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 404
  end
end
