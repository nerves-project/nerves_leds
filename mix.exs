defmodule Nerves.IO.Leds.Mixfile do

  use Mix.Project
  
  def project, do: [
    app: :nerves_io_leds,
    version: version,
    elixir: "~> 1.0",
    deps: deps,
    name: "Nerves.IO.Leds",
    description: "Functions to drive LEDs on embedded systems",
    package: package,
    docs: [
      source_ref: "v#{version}", main: "Nerves.IO.leds",
      source_url: "https://github.com/nerves-project/nerves_io_leds",
      main: "extra-readme",
      extras: [ "README.md", "CHANGELOG.md"]
    ]    
  ]

  def application, do: [ ]

  defp deps, do: [
    {:earmark, "~> 0.1", only: :dev},
    {:ex_doc, "~> 0.8", only: :dev}
  ]

  defp package, do: [
    maintainers: ["Garth Hitchens", "Chris Dutton"],
    licenses: ["MIT"],
    links: %{github: "https://github.com/nerves-project/nerves_io_leds"},
    files: ~w(lib config) ++
           ~w(README.md CHANGELOG.md LICENSE mix.exs)
  ]
  
  defp version do
    case File.read("VERSION") do
      {:ok, ver} -> String.strip ver
      _ -> "0.0.0-dev"
    end
  end
end
