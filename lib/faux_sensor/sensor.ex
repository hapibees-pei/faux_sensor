defmodule FauxSensor.Sensor do
  use Agent
  alias FauxSensor.Gateway

  @type sensor :: %{
          :id => {integer() | nil},
          :gateway => pid()
        }
  @type data :: %{
          :date => term(),
          :hieve_id => integer(),
          :apiary_id => term(),
          :temperature => float(),
          :pressure => float(),
          :light => float(),
          :noise => float(),
          :humidity => float(),
          :accelerometer => float()
        }

  def start() do
    Gateway.add_sensor(self())
    wake_up()
  end

  def wake_up do
    reading()

    receive do
    after
      10_000 ->
        wake_up()
    end
  end

  def reading do
    Gateway.send_to_mqtt(self(), data())
  end

  # Generate fake data
  def data do
  end
end
