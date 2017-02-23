defmodule Nerves.Leds do

  @moduledoc """
  A convenient interface to setting LEDs defined in `/sys/class/leds`.

  While an application could write directly to /sys/class/leds, the main advantage
  of using this module is to provide a layer of abstraction that allows easily
  defining application-specific led names and states, like this:

  ```elixir
  alias Nerves.Leds

  Leds.set power: true                            # turn on the led we called "power"
  Leds.set power: :slowblink                      # make it blink slowly
  Leds.set connected: false, alert: :fastblink    # set multiple LED states at once

  ## alernate syntax via set/2

  Leds.set :power, :slowblink

  ```

  ## Configuration

  Use config.exs in your application to create a friendly name that maps to an
  entry in `/sys/class/leds` that make sense for your application.

  A trivial example for Raspberry Pi:

  ```elixir
  # in your app's config/config.exs:
  config :nerves_leds, names: [ red: "led0", green: "led1" ]
  ```

  A more useful example for the Alix 2D boards implementing a router:

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

  @doc """
  Set states of one or more LEDs by using their mapped name

  ~~~elixir
    Nerves.Leds.set power: true, error: :fastblink
  ~~~
  """

  @spec set(Keyword.t) :: true
  def set(settings) do
    Enum.each settings, fn({led, state}) ->
      set(led, state)
    end
    true
  end

  @doc """
  Set the state of a single LED

  ~~~elixir
  Nerves.Leds.set :power, true
  Nerves.Leds.set :backlight, brightness: 200
  ~~~

  Note that unlike set/1, this allows optionally directly naming the file of the led
  in /sys/class/leds by using a string name rather than an atom.

  ~~~elixir
  Nerves.Leds.set "led2", [ trigger: "timer", delay_on: 1000, delay_off: 1000 ]
  ~~~
  """

  @spec set(atom | binary, atom | Keyword.t) :: true
  def set(led, state) do
    set_raw_state raw_led(led), raw_state(state)
  end

  ### private ###

  defp led_path(led, attribute) do
    Path.join @sys_leds_path, "#{led}/#{attribute}"
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
    {trigger, settings} = Keyword.pop settings, :trigger, "none"
    write(led, {:trigger, trigger})
    Enum.each settings, &(led |> write(&1))
  end

  # if parameter isn't a list, lookup state from state map or predefined states
  defp raw_state(val) when is_list(val), do: val
  defp raw_state(val) when is_integer(val), do: Integer.to_string(val)
  defp raw_state(val) when is_atom(val) do
    @app
    |> Application.get_env(:states, [])
    |> Keyword.merge(@predefined_states)
    |> Keyword.get(val)
    |> case do
      nil ->
        raise ArgumentError, "Attempt to set unknown LED state: #{inspect val}"
      state ->
        state
    end
  end

  # if parameter isn't a string, lookup led name from configured led name map
  defp raw_led(key) when is_binary(key), do: key
  defp raw_led(key) when is_atom(key) do
    @app
    |> Application.get_env(:names, [])
    |> Keyword.get(key)
    |> case do
      nil ->
        raise ArgumentError, """
        Attempt to set unknown LED key: #{inspect key}.
        Check your LED names in config.exs.
        """
      led ->
        led
    end
  end
end
