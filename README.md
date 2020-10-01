# Nerves.Leds

[![Build Status](https://travis-ci.org/nerves-project/nerves_leds.svg?branch=master)](https://travis-ci.org/nerves-project/nerves_leds)
[![Hex version](https://img.shields.io/hexpm/v/nerves_leds.svg "Hex version")](https://hex.pm/packages/nerves_leds)

Simple API to drive leds exposed by linux `/sys/class/leds`.  Designed for use with [Nerves](http://nerves-project.org/), but works on any distribution of Linux with `/sys/class/leds`.

## Installation

Add `nerves_leds` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:nerves_leds, "~> 0.8.0"}]
end
```

## Configuration & Usage

Configure your LEDs mappings:

```elixir
# config/config.exs
config :nerves_leds, names: [ error: "led0", connect: "led1" ]
```

Now, you can use predefined states in your app:

```elixir
alias Nerves.Leds

Leds.set(connect: true)
Leds.set(connect: :heartbeat)
Leds.set(connect: false, error: :slowblink)
```

You can also define your own states:

```elixir
# config/config.exs
config :nerves_leds, states: [
    fastblink: [ trigger: "timer", delay_off: 40, delay_on: 30 ],
    blip: [ trigger: "timer", delay_off: 1000, delay_on: 100 ]]
```

For situations where the number of LEDs are not known at compile time, you
can enumerate the LEDs:

```elixir
Leds.enumerate()
```

## More Details

See the [documentation](https://hexdocs.pm/nerves_leds) for the full description of the API and configuration.
