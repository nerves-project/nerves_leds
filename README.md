Nerves.Leds
===========
[![Build Status](https://travis-ci.org/nerves-project/nerves_io_led.svg?branch=master)](https://travis-ci.org/nerves-project/nerves_leds)

Simple API to drive leds exposed by linux `/sys/class/leds`.
Designed for use with [nerves](http://nerves-project.org/),
but works on any distribution of Linux that supports `/sys/class/leds`.

## Configuration

Use config.exs to create a friendly name that maps to an entry in
`/sys/class/leds` that make sense for your application.

An example configuration for the Alix 2D boards:

```elixir
# in your app's config/config.exs:
config :nerves_leds, names: [
	power:     "alix:1",
	connected: "alix:2",
	alert:     "alix:3"
]
```
## Usage

It's customary to bring the Nerves.Leds module into scope as "Leds", as follows:
```elixir
alias Nerves.Leds
```
Now, we can turn an LED on using the name we configured:
```elixir
Leds.set power: true
```
Or make it blink slowly:
```elixir
Leds.set power: :slowblink
```
We can even set multiple states for multiple LEDs at once:
```elixir
Leds.set connected: false, alert: :fastblink
```
## Built-In LED States

In addition to `true` (on) and `false` (off) the following atoms provide predefined
behaviors:

- `:slowblink` - turns on and off slowly (about twice a second)
- `:fastblink` - turns on and off rapidly (about 7.5 times a second)
- `:slowwink` - mostly on, but "winks off" once every second or so
- `:heartbeat` - a heartbeat pattern

## Customizing states

The standard LED states are defined as `@predefined_states` near the top of
`lib/nerves_leds.ex`. You can change or add to them using config.exs as
follows:

```elixir
config :nerves_leds, states: [
	fastblink: [ trigger: "timer", delay_off: 40, delay_on: 30 ],
	blip: [ trigger: "timer", delay_off: 1000, delay_on: 100 ]]
```

See the Linux documentation on `sys/class/leds` to understand the meaning of
trigger, delay, brightness, and other settings.

## Limitations, Areas for Improvement

- most but not all ``/sys/class/leds` features are currently implemented
