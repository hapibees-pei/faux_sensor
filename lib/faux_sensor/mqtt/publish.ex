defmodule FauxSensor.Mqtt.Publish do
  @id "faux"
  def send_gateway_status(uuid) do
    Tortoise.publish(@id, "gateway/#{uuid}/status", "up")
  end

  def send_sensor_status(uuid, id) do
    Tortoise.publish(@id, "gateway/#{uuid}/sensors/#{id}/status", "up")
  end

  def send_data(uuid, id, data) do
    Tortoise.publish(@id, "gateway/#{uuid}/sensors/#{id}", data)
  end
end
