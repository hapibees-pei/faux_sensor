defmodule FauxSensor do
  alias FauxSensor.Gateway
  alias FauxSensor.Sensor

  def new(ip, port) do
    Gateway.init(ip, port)

    for _n <- 0..1, do: Sensor.start_link()
  end
end
