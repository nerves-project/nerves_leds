# Changelog

## v0.7.0 (2016-06-21)

This update reflects a number of changes that bring this module more in line
with current Nerves and Elixir naming, coding, and license conventions, in
preparation for pushing to hex. Unfortunately it changes the API, but hey,
we're still < 1.0, right?

* Breaking API Changes
  - Renamed project to `nerves_leds` (was `nerves_io_led`)
  - Module is now Nerves.Leds (was Nerves.Led)
  - Removed the `alive` functionality (can use `oneshot` trigger instead)
* Improved code style in places and fixed warnings
* Improved and fixed bugs in docs
* Changed LICENSE to Apache 2

## v0.6.0 (2015-10-04)

* Breaking API Changes
  - app_name is now `nerves_io_led` for config.exs
  - changed configuration options to avoid confusing 'map' terminology
	- config option `name_map` is now just `names`
	- config option `state_map` is now just `states`

## v0.5.0 (2015-10-01)

* Move from Cellulose to Nerves Project
* Scope as Nerves.IO.Leds
* Add support for ExDoc
* Clean up README.md
* Add package support
