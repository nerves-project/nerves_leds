defmodule Nerves.Leds.Mixfile do

  @version "0.7.0"

  use Mix.Project

  def project do
    [ app: :nerves_leds,
      version: @version,
      elixir: "~> 1.0",
      deps: deps(),
      description: "Functions to drive LEDs on embedded systems",
      package: package(),
      name: "Nerves.Leds",
      description: "Functions to drive LEDs on embedded systems",
      docs: [
        source_ref: "v#{@version}", main: "Nerves.Leds",
        source_url: "https://github.com/nerves-project/nerves_leds",
#        main: "extra-readme",
        extras: [ "README.md", "CHANGELOG.md"] ]]
  end

  def application do
    []
  end

  defp deps do
    [{:ex_doc, "~> 0.11", only: :dev}]
  end

  defp package do
    [ maintainers: ["Garth Hitchens", "Chris Dutton"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/nerves-project/nerves_leds"},
      files: ~w(lib config) ++ ~w(README.md CHANGELOG.md LICENSE mix.exs) ]
  end

end
