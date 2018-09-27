defmodule INI.MixProject do
  use Mix.Project

  def project do
    [
      app: :ini,
      version: "0.0.1",
      elixir: "~> 1.5",
      test_coverage: [tool: ExCoveralls],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:excoveralls, "~> 0.10", only: :test}]
  end
end
