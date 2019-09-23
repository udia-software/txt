defmodule U0txt.MixProject do
  use Mix.Project

  def project do
    [
      app: :u0txt,
      version: "1.0.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      included_applications: [:mnesia],
      mod: {U0txt.Application, []}
    ]
  end

  defp deps do
    [{:plug_cowboy, "~> 2.0"}, {:distillery, "~> 2.1"}]
  end
end
