defmodule FauxSensor do
  alias FauxSensor.Gateway

  def new(ip, port) do
    Gateway.init(ip, port)
  end
end
