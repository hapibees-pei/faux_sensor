defmodule FauxSensor.Sensor do
  use Agent

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
  def init do
  end

  def reading do
  end

  def wake_up do
  end
end
