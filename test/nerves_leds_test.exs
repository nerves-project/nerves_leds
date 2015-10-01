defmodule Nerves.LedsTest do

  use ExUnit.Case
  alias Nerves.Leds
  
	# callback for the test led that simply sets keys in the process dictionary
  # where we can assert them.  This works because the LED module does
  # everything in process.
  def on_led_write({k, v}), do: Process.put(k, v)

  defp led(key), do: Process.get(key) 
 
  test "turning on an LED" do
		Leds.set test_led: true
	  assert led(:brightness) == "1"
		assert led(:trigger) == "none"
  end

  test "turn off an LED" do
		Leds.set test_led: false
	  assert led(:brightness) == "0"
		assert led(:trigger) == "none"
  end

  test "test a complex state" do
		Leds.set test_led: :slowwink
		assert led(:trigger) == "timer"
		assert led(:delay_on) == "1000"
    assert led(:delay_off) == "100"
  end

  test "custom state map" do
		Leds.set test_led: :test_state
		assert led(:foo) == "3"
    assert led(:bar) == 29
    assert led(:baz) == %{}
  end

end
