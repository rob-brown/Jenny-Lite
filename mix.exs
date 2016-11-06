defmodule JennyLite.Mixfile do
  use Mix.Project

  def project do
    [
      app: :jenny_lite,
      version: "0.1.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      escript: escript,
      deps: deps(),
   ]
  end

  def application do
    [applications: [:logger]]
  end

  defp escript do
    [main_module: JennyLite.CLI]
  end

  defp deps do
    [
      {:poison, "~> 3.0.0"},
    ]
  end
end
