defmodule FauxSensor.QrCode do
  require Logger

  def generate(ip, port) do
    link = "http://localhost:3000/apiary?ip=#{ip}&port=#{port}"
    Logger.info(link)
    link
  end
end
