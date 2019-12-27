defmodule FauxSensor.Sensor do
  use GenServer
  require Logger
  alias FauxSensor.Gateway

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    send(self(), :start)
    {:ok, state}
  end

  def handle_info(:start, state) do
    #Logger.info("start")

    if Gateway.add_sensor(self()) < 0 do
      Process.send_after(self(), :start, 1_000)
    else
      start_transmite()
    end

    {:noreply, state}
  end

  def handle_info(:wake_up, state) do
    #Logger.info("wake up")
    wake_up()

    {:noreply, state}
  end

  def wake_up do
    reading()
    start_transmite()
  end

  def reading do
    {:ok, read} = data()
    Gateway.send_to_mqtt(self(), read)
  end

  # Generate fake data
  def data do
    {:ok, message} = Circuits.UART.read(Circuits, 60000)
    IO.inspect message
    
    Jason.encode(%{
      :date => Timex.now(),
      :temperature => random(),
      :pressure => random(),
      :light => random(),
      :noise => random(),
      :humidity => random(),
      :accelerometer => 0
    }, encode: :unicode_safe)
  end

  def start_transmite do
    Process.send_after(self(), :wake_up, 5_000)
  end

  def random do
    :rand.uniform(50)
  end
end
