defmodule FauxSensorTest do
  use ExUnit.Case
  doctest FauxSensor

  test "greets the world" do
    assert FauxSensor.hello() == :world
  end
end
