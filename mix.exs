defmodule Icu.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :icu,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_parsec, "~> 0.5.0"},
      # Internationalization utilities
      {:ex_cldr, "~> 2.0"},
      {:ex_cldr_numbers, "~> 2.1"},
      {:ex_cldr_lists, "~> 2.0"},
      {:ex_cldr_units, "~> 2.1"},
      # JSON decoder library
      {:jason, "~> 1.0"},
      {:stream_data, "~> 0.4.2", only: [:test, :dev]}
    ]
  end
end
