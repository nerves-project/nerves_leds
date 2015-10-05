Nerves.IO.Leds
==============

Simple control of LEDs.  Designed for use with [nerves](http://nerves.io/), but works on any distribution of linux that supports `/sys/class/leds`.

## Configuration

Use config.exs to create a friendly name that maps to an entry in /sys/class/leds that make sense for your application.

An example configuration for the Alix 2D boards:

	# in your app's config/config.exs: 
	config :nerves_io_leds, name_map: [
		power:     "alix:1", 
		connected: "alix:2",
		alert:     "alix:3"
	]

## Usage

It's customary to bring the Nerves.Leds module into scope as "Leds", as follows:

    alias Nerves.IO.Leds

Now, we can turn an LED on using the name we configured:

    Leds.set power: true

Or make it blink slowly:

    Leds.set power: slowblink

We can even set multiple states for multiple LEDs at once:

Leds.set connected: false, alert: :fastblink

## Built-In LED States

In addition to `true` (on) and `false` (off) the following atoms have built-in meaning to the LEDs module.

- `:slowblink` - turns on and off slowly (about twice a second)
- `:fastblink` - turns on and off rapidly (about 7.5 times a second)
- `:slowwink` - mostly on, but "winks off" once every second or so
- `:hearbeat` - a heartbeat pattern 

## Keep-Alive LEDs

One common scenario in embedded programming involves keeping an LED on as long as something happens once in a while (like keeping a connection light lit as data keeps coming).  Do it like this:

	Leds.alive :connected, 2000

This will illuminate the LED for 2 seconds, after which it will extinguish.  By repeating the above call within 2 seconds, the LED is kept on indefinitely.

## Customizing LED states

The standard LED states are defined as `@predefined_states` near the top of `lib/nerves_io_leds.ex`.  You can change or add to them using config.exs as follows:

	config :nerves_io_leds, :state, [ 
		fastblink: [ trigger: "timer", delay_off: "40", delay_on: 30" ],
		blip: [ trigger: "timer", delay_off: "1000", delay_on: "100" ]
	]

See the linux documentation on sys/class/leds to understand the meaning of trigger, delay, brightness, and other settings.

## Limitations, Areas for Improvement

- linux only, requires /sys/class/leds
- most but not all /sys/class/leds features are currently implemented
- tests don't cover keepalive functionality yet
