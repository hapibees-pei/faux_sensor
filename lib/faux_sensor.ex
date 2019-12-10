defmodule FauxSensor do
  alias FauxSensor.Gateway
  alias FauxSensor.Sensor

  def new(ip, port) do
    Gateway.init(ip, port)

    Sensor.start_link()
    Sensor.start_link()
  end
end
