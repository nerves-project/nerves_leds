defmodule Leds.Mixfile do

  use Mix.Project

  def project, do: [
    app: :leds,
    version: version,
    elixir: "~> 1.0",
    deps: deps
  ]

  def application, do: [ ]

  defp deps, do: [
    {:earmark, "~> 0.1", only: :dev},
    {:ex_doc, "~> 0.7", only: :dev}
  ]

  defp version do
    case File.read("VERSION") do
      {:ok, ver} -> String.strip ver
      _ -> "0.0.0-dev"
    end
  end
end
