defmodule FauxSensor.Gateway do
  use Agent

  alias FauxSensor.Sensor
  alias FauxSensor.QrCode
  alias FauxSensor.TcpServer

  def init(ip, port) do
    QrCode.generate(ip, port)
    {:ok, pid} = TcpServer.start_link(ip, port)
    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, :process, ^pid, :normal} ->
        IO.puts("Normal exit from #{inspect(pid)}")

      {:DOWN, ^ref, :process, ^pid, msg} ->
        IO.puts("Received :DOWN from #{inspect(pid)}")
        IO.inspect(msg)
    end
  end

  def add_sensor(gateway_pid) do
    Sensor.init(gateway_pid)
  end
end
