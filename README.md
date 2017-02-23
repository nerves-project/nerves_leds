Nerves.Leds
===========
[![Build Status](https://travis-ci.org/nerves-project/nerves_leds.svg?branch=master)](https://travis-ci.org/nerves-project/nerves_leds)
[![Hex version](https://img.shields.io/hexpm/v/nerves_leds.svg "Hex version")](https://hex.pm/packages/nerves_leds) [![Ebert](https://ebertapp.io/github/nerves-project/nerves_leds.svg)](https://ebertapp.io/github/nerves-project/nerves_leds)

Simple API to drive leds exposed by linux `/sys/class/leds`.  Designed for use with [Nerves](http://nerves-project.org/), but works on any distribution of Linux with `/sys/class/leds`.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `nerves_leds` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:nerves_leds, "~> 0.8.0"}]
  end
  ```

  2. List `:nerves_leds` as an application dependency:

  ```elixir
  def application do
    [applications: [:nerves_leds]]
  end
  ```

  4. Run `mix deps.get` and `mix compile`


### Configuration & Usage

Configure your LEDs mappings:

```elixir
# config/config.exs
config :nerves_leds, names: [ error: "led0", connect: "led1" ]
```

Now, you can use predefined states in your app:

```elixir
alias Nerves.Leds

Leds.set connect: true
Leds.set connect: :heartbeat
Leds.set connect: false, error: :slowlbink
```

You can also define your own states:

```elixir
# config/config.exs
config :nerves_leds, states: [
	fastblink: [ trigger: "timer", delay_off: 40, delay_on: 30 ],
	blip: [ trigger: "timer", delay_off: 1000, delay_on: 100 ]]
```

### More Details

See the [documentation](https://hexdocs.pm/nerves_leds) for the full description of the API and configuration.
