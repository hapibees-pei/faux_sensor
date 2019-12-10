defmodule FauxSensor.Mqtt.Publish do
  @id "faux_sensor"
  def send_gateway_status(uuid) do
    Tortoise.publish(@id, "gateway/#{uuid}/status", "up")
  end

  def send_sensor_status(uuid, id) do
    Tortoise.publish(@id, "gateway/#{uuid}/sensor/#{id}/status", "up")
  end

  def send_data(uuid, id, data) do
    Tortoise.publish(@id, "gateway/#{uuid}/sensor/#{id}", data)
  end
end
