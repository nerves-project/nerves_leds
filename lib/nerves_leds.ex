defmodule Nerves.Leds do

  @moduledoc """
  Handles LED blinking/handling in a configurable way, providing an
  easy-to use interface to setting LEDs defined in `/sys/class/leds`.

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
  Set status of one or more leds, like this:

  ```
  Nerves.Leds.set power: true, error: fastblink
  ```

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
