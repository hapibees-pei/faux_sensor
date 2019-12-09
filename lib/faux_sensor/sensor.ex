defmodule FauxSensor.Sensor do
  use Agent

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

  def init(gateway_id) do
  end

  def reading do
  end

  def wake_up do
  end
end
