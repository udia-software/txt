defmodule U0txt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc "OTP Application specification for u0txt"

  use Application

  def start(_type, _args) do
    port = Application.get_env(:u0txt, :port)

    children = [
      # Using Plug.Cowboy.child_spec/3 for registering endpoint
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: U0txt.Endpoint,
        # port depends on environment, see ./config/MIX_ENV.exs
        options: [port: port]
      )
    ]

    n = node()
    IO.inspect(n)

    case :mnesia.create_schema([n]) do
      :ok -> nil
      {:error, {^n, {:already_exists, host}}} -> IO.puts("Existing schema at #{host}")
    end

    :ok = :mnesia.start()

    case :mnesia.create_table(:txt, attributes: [:id, :body], disc_copies: [n]) do
      {:atomic, :ok} -> nil
      {:aborted, {:already_exists, :txt}} -> nil
    end

    IO.puts("Starting server on #{port}...")
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: U0txt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def stop(_state) do
    :mnesia.stop()
  end
end
