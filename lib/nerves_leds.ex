defmodule Nerves.Leds do

  @moduledoc """
  Handles LED blinking/handling in a configurable way, providing an
  easy-to use interface to setting LEDs defined in `/sys/class/leds`.

  While an application could write directly to /sys/class/leds, the main advantage
  of using this module is to provide a layer of abstraction that allows easily
  defining application-specific led names and states, like this:

  ```elixir
  alias Nerves.Leds

  Leds.set power: true                            # turn on the led we called "power"
  Leds.set power: :slowblink                      # make it blink slowly
  Leds.set connected: false, alert: :fastblink    # set multiple LED states at once
  ```

  ## Configuration

  Use config.exs to create a friendly name that maps to an entry in
  `/sys/class/leds` that make sense for your application. An example for the Alix 2D boards:

  ```elixir
  # in your app's config/config.exs:
  config :nerves_leds, names: [
  	power:     "alix:1",
  	connected: "alix:2",
  	alert:     "alix:3"
  ]
  ```

  ## Included states

  In addition to `true` (on) and `false` (off) the following atoms provide predefined
  behaviors:

  - `:slowblink` - turns on and off slowly (about twice a second)
  - `:fastblink` - turns on and off rapidly (about 7.5 times a second)
  - `:slowwink` - mostly on, but "winks off" once every second or so
  - `:hearbeat` - a heartbeat pattern

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
  """

  @app :nerves_leds

  @predefined_states [
    true:  [ brightness: 1 ],
    false: [ brightness: 0 ],
    slowblink: [ trigger: "timer", delay_off: 250, delay_on: 250 ],
    fastblink: [ trigger: "timer", delay_off: 80, delay_on: 50 ],
    slowwink:  [ trigger: "timer", delay_on: 1000, delay_off: 100 ],
    heartbeat: [ trigger: "heartbeat" ]
  ]

  @sys_leds_path "/sys/class/leds/"

  @led_names  Application.get_env(@app, :names, [])
  @led_states Dict.merge(Application.get_env(@app, :states, []), @predefined_states)

  @doc """
  Set one or more leds to one of the built-in or user-defined states

  ~~~elixir
    Nerves.Leds.set power: true, error: :fastblink
  ~~~

  See the module overview for information about states and configuration.
  """

  @spec set(Keyword.T) :: true
  def set(settings) do
    Enum.each settings, &(set_keyed_state(&1))
    true
  end

  ### private ###

  defp led_path(led, attribute) do
    Path.join  @sys_leds_path, "#{led}/#{attribute}"
  end

  # if the value of a defined LED is a function, then call the function
  # with the key/value arguments Primarly used for testing
  defp write(led_fn, {key, value}) when is_function(led_fn) do
    led_fn.({key, value})
  end
  defp write(led, {key, value}) when is_binary(led) do
    File.write(led_path(led, key), to_string(value))
  end

  defp set_raw_state(led, settings) do
    {trigger, settings} = Dict.pop settings, :trigger, "none"
    write(led, {:trigger, trigger})
    Enum.each settings, &(led |> write(&1))
  end

  defp set_keyed_state({key, val}) do
     set_raw_state raw_led(key), raw_state(val)
  end

  defp raw_state(val) when is_list(val), do: val
  defp raw_state(val), do: Dict.get @led_states, val

  defp raw_led(key) do
    case (Dict.get @led_names, key) do
        nil ->
          raise ArgumentError, """
          Attempt to set unknown led key. Check your led names in config.exs,
          or maybe you forgot to mix deps.compile leds after change?
          """
        led -> led
    end
  end

end
