defmodule FauxSensor.TcpServer do
  use GenServer
  require Logger

  alias FauxSensor.Gateway

  def start_link(ip, port) do
    GenServer.start_link(__MODULE__, [ip, port], [])
  end

  def init([ip, port]) do
    ip =
      if ip != "127.0.0.1" do
        "0.0.0.0"
      end

    ip_tuple = ip_to_tuple(ip)

    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, {:packet, 0}, {:active, true}, {:ip, ip_tuple}])

    send(self(), :accept)
    {:ok, %{socket: socket}}
  end

  def handle_info(:accept, %{socket: socket} = state) do
    {:ok, _} = :gen_tcp.accept(socket)

    Logger.info("Client connected")
    {:noreply, state}
  end

  def handle_info({:tcp, socket, packet}, state) do
    Logger.info("income")

    with {:ok, %{"ip" => ip, "port" => port, "uuid" => uuid}} <- Jason.decode(packet) do
      :gen_tcp.send(socket, "success")

      Gateway.set_internal_state(%{"ip" => ip, "port" => port, "uuid" => uuid})

      {:stop, :normal, []}
    else
      _ -> {:noreply, state}
    end
  end

  def handle_info({:tcp_closed, _}, state), do: {:stop, :normal, state}
  def handle_info({:tcp_error, _}, state), do: {:stop, :normal, state}

  defp ip_to_tuple(ip) do
    list = String.split(ip, ".")
    parse_to_int = Enum.map(list, fn x -> String.to_integer(x) end)
    List.to_tuple(parse_to_int)
  end
end
