defmodule BasecoatPhoenix.MixProject do
  use Mix.Project

  def project do
    [
      app: :basecoat_phoenix,
      version: "0.3.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      description: "Basecoat UI components for Phoenix LiveView",
      package: package()
    ]
  end

  def application, do: [extra_applications: [:logger, :crypto]]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix_live_view, "~> 1.2"},
      {:phoenix_html, "~> 4.0"},
      {:jason, "~> 1.4"},
      {:floki, "~> 0.36", only: :test},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      files: ~w(lib priv mix.exs README.md LICENSE .formatter.exs)
    ]
  end
end
