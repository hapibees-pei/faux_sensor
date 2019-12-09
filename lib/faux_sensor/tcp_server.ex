defmodule FauxSensor.TcpServer do
  use GenServer

  def start_link(ip \\ {127, 0, 0, 1}, port \\ 6666) do
    GenServer.start_link(__MODULE__, [ip, port], [])
  end

  def init([ip, port]) do
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, {:packet, 0}, {:active, true}, {:ip, ip}])

    {:ok, socket} = :gen_tcp.accept(listen_socket)
    {:ok, %{ip: ip, port: port, socket: socket}}
  end

  def handle_info({:tcp, socket, packet}, state) do
    IO.inspect(packet, label: "incoming packet")
    :gen_tcp.send(socket, "success")
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    IO.inspect("Socket has been closed")
    {:noreply, state}
  end

  def handle_info({:tcp_error, socket, reason}, state) do
    IO.inspect(socket, label: "connection closed dut to #{reason}")
    {:noreply, state}
  end
end
