defmodule FauxSensor.Sensor do
  use GenServer
  require Logger
  alias FauxSensor.Gateway

  def start_link() do
    GenServer.start_link(__MODULE__, %{buffer: "", id: 0})
  end

  def init(state) do
    send(self(), :start)
    {:ok, state}
  end

  def handle_info(:start, state) do
    # Logger.info("start")

    if Gateway.add_sensor(self()) < 0 do
      Process.send_after(self(), :start, 1_000)
    else
      start_transmite()
    end

    {:noreply, state}
  end

  def handle_info(:wake_up, state) do
    # Logger.info("wake up")
    wake_up()

    {:noreply, state}
  end

  def handle_info(:data, state) do
    {:ok, message} = Circuits.UART.read(Circuits, 60000)
    buffer = state.buffer <> message
    IO.inspect(buffer, label: "[RAW]")
    split_array = String.split(buffer, "}")
    IO.inspect(split_array, label: "[SPLIT]")

    if length(split_array) > 1 do
      droped = Enum.drop(split_array, -1)

      Enum.each(
        droped,
        fn x -> Gateway.send_to_mqtt(self(), parse(x <> "}")) end
      )
      new_state = %{buffer: List.last(split_array)}
      {:noreply, Map.merge(state, new_state)}
    else
      new_state = %{buffer: buffer}
      {:noreply, Map.merge(state, new_state)}
    end
  end

  defp parse(json) do
    {:ok, data} = Jason.decode(String.trim(json))
    split_array = String.split(data["reading"], "&") 
    IO.inspect(split_array, label: "json")
    Jason.encode!(%{
      :date => Timex.now(),
      :temperature => Enum.at(split_array, 0) |> String.to_integer(),
      :pressure => Enum.at(split_array, 1) |> String.to_float(),
      :light => Enum.at(split_array, 2) |> String.to_float(),
      :noise => Enum.at(split_array, 3) |> String.to_float(),
      :humidity => Enum.at(split_array, 1) |> String.to_float(), #TODO: build correct json on sensor
      :accelerometer => Enum.at(split_array, 1) |> String.to_float(),
    }, encode: :unicode_safe)
  end

  def wake_up do
    reading()
    start_transmite()
  end

  def reading do
    send(self(), :data)
    #{:ok, read} = data()
    #Gateway.send_to_mqtt(self(), read)
  end

  # Generate fake data
  # def data do
  #   {:ok, message} = Circuits.UART.read(Circuits, 60000)
  #   IO.inspect message
  #   
  #   Jason.encode(%{
  #     :date => Timex.now(),
  #     :temperature => random(),
  #     :pressure => random(),
  #     :light => random(),
  #     :noise => random(),
  #     :humidity => random(),
  #     :accelerometer => 0
  #   }, encode: :unicode_safe)
  # end

  def start_transmite do
    Process.send_after(self(), :wake_up, 5_000)
  end

  def random do
    :rand.uniform(50)
  end
end
