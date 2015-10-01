Nerves.Leds
===========

A simple module to make it easy to control LEDs.  Works on any linux system with /sys/class/leds.

### Basic Configuration & Usage

Assign a friendly name to each LED that makes sense for your application.
An example configuration for the Alix 2D boards:

	# in your app's config/config.exs: 

	config :leds, name_map: [
		power:     "alix:1", 
		connected: "alix:2",
		alert:     "alix:3"
	]

It's customary to bring the Nerves.Leds module into scope as "Leds", as follows:

    alias Nerves.Leds

Now, in our application code, we can easily use an LED:

    Leds.set power: true

We can even set multiple states for multiple LEDs at once:

    Leds.set connected: false, alert: :fastblink

### LEDs and Keep-Alive

There's also built-in handling for the common scenario where we want to keep an LED on as long as something happens once in a while (like keeping a connection light lit as data keeps coming).

	Leds.alive :connected, 2000

Normally, this will illuminate the LED for 2 seconds, but by repeating the above call within 2 seconds, the LED is kept on indefinitely.

### Custom LED states

LEDs have several states predefined, but you can override the default set of states in config.exs:

    # in your app's config/config.exs:

	config :leds, :state_map, [
		true:      [ brightness: "1" ],
		false:     [ brightness: "0" ],
		slowblink: [ trigger: "timer", delay_off: "250", delay_on: "250" ],
		fastblink: [ trigger: "timer", delay_off: "80", delay_on: "50" ],
		slowwink:  [ trigger: "timer", delay_on: "1000", delay_off: "100" ],
		heartbeat: [ trigger: "heartbeat" ]
    ]

The above example shows a custom set of states (which happen to be the default settings).  See the linux documentation on sys/class/leds to understand the meaning of trigger, delay, and brightness levels.

### Limitations, Areas for Improvement

- linux only, requires /sys/class/leds
- most but not all /sys/class/leds features are currently implemented
- must currently redefine all states upon customization (can't add one)
- tests don't cover keepalive functionality yet


