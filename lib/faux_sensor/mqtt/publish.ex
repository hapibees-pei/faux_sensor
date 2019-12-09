defmodule FauxSensor.Mqtt.Publish do
  def send_message(id, topic, message) do
    Tortoise.publish(id, topic, message)
  end
end
