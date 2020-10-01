defmodule Nerves.Leds.MixProject do
  use Mix.Project

  @version "0.8.1"
  @source_url "https://github.com/nerves-project/nerves_leds"

  def project do
    [
      app: :nerves_leds,
      version: @version,
      elixir: "~> 1.4",
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs(),
      preferred_cli_env: %{
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs
      }
    ]
  end

  def application do
    []
  end

  defp description do
    "Functions to drive LEDs on embedded systems"
  end

  defp deps do
    [{:ex_doc, "~> 0.22", only: :docs, runtime: false}]
  end

  defp package do
    [
      files: ~w(lib config) ++ ~w(README.md CHANGELOG.md LICENSE mix.exs),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "Nerves.Leds",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
