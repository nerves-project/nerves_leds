defmodule Leds do

  @moduledoc """
  Handles LED blinking/handling in a configurable way, providing an
  easy-to use interface to setting LEDs defined in /sys/class/leds:

		Leds.set power: true, alert: false, network: :fastblink

  """

  @sys_leds_path "/sys/class/leds"

  @name_map  Application.get_env :leds, :name_map, []

  @state_map Application.get_env :leds, :state_map, [
		true:  [ brightness: "1" ],
    false: [ brightness: "0" ],
		slowblink: [ trigger: "timer", delay_off: "250", delay_on: "250" ],
		fastblink: [ trigger: "timer", delay_off: "80", delay_on: "50" ],
		slowwink:  [ trigger: "timer", delay_on: "1000", delay_off: "100" ],
		heartbeat: [ trigger: "heartbeat" ]
  ]

  def initialize do
    :ets.new :led_alive_processes, [:set, :public, :named_table]
  end

  defp led_path(led, attribute) do
    Path.join  @sys_leds_path <> "#{led}/", attribute
  end

  # if the value of a defined LED is a function, then call the function
  # with the key/value arguments   Primarly used for testing
  defp write(led_fn, {key, value}) when is_function(led_fn) do
		led_fn.({key, value})
  end
  defp write(led, {key, value}) when is_binary(led) do
    if is_atom(key), do: key = :erlang.atom_to_binary(key, :utf8)
    File.write(led_path(led, key), value)
  end

  defp set_raw_state(led, settings) do
    {trigger, settings} = Dict.pop settings, :trigger, "none"
    write(led, {:trigger, trigger})
    Enum.each settings, &(led |> write &1)
  end

  defp set_keyed_state({key, val}) do
    raw_led = Dict.get @name_map, key
    unless is_list(val), do: val = Dict.get @state_map, val
    set_raw_state raw_led, val
  end

  defp hold(led, ms) do
    set_keyed_state({led, true})
    :timer.sleep ms
    set_keyed_state({led, false})
  end

  @doc """
  Keeps an led on for the specified amount of time - 5 secs default

  Written in such a way that you can call alive from multiple processes,
  and they will overlap - i.e. each call resets the timer to another time
  period.  If the specified timeout is different, the last timout called
  is the timeout that is used.   When the timeout expires (with no other
  alive call for that led) the led is extinguished.

  The following example shows turning on an led labelled :activity.  The
  call must be executed every 2 seconds or more to keep the activity led
  lit:

      Leds.alive :activity, 2000

  WARNING: This is a moderate overhead function, and shouldn't be called
           every millisecond.  It's intended for longer intervals.  This
           could be fixed.  Pull requests welcomed.
  """
  def alive(led, ms \\ 5000) do
    pinger_pid = :erlang.spawn fn() -> hold(led, ms) end
    case :ets.lookup(:led_alive_processes, led) do
      [{^led, old_pid}] -> Process.exit(old_pid, :replaced)
      _ -> nil
    end
    :ets.insert :led_alive_processes, [{led, pinger_pid}]
  end

  @doc """
  Set led status.  Settings is an enumerable k/v.
  Like this: Leds.set power: true
  """
  def set(settings) do
    Enum.each settings, &(set_keyed_state(&1))
  end
end
