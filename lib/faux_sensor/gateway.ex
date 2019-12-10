defmodule FauxSensor.Gateway do
  use Agent

  alias FauxSensor.Sensor
  alias FauxSensor.QrCode
  alias FauxSensor.TcpServer

  def init(ip, port) do
    TcpServer.start_link(ip, port)

    Agent.start_link(fn -> %{count: 0, pids: %{}, ip: nil, port: nil, uuid: nil} end,
      name: __MODULE__
    )

    send_request_create(ip, port)

    QrCode.generate(ip, port)
  end

  def add_sensor(pid) do
    # TODO adicionar o novo pid do sensor ao state, meter nos map dos pids e count++
    Agent.update(__MODULE__, fn state -> state end)
    # enviar msg para o gateway/uuid/sensor/id/status
  end

  def set_internal_state(internal) do
    Agent.update(__MODULE__, fn state -> Map.merge(state, internal) end)
    # iniciar mqtt
    # enviar msg para o gateway/uuid/status
  end

  def send_to_mqtt(sensor_pid, data) do
    Agent.get(__MODULE__, fn %{pids: pids} = _state -> pids end)
  end

  def send_request_create(ip, port) do
    Application.ensure_all_started(:inets)

    {:ok, params} = Jason.encode(%{onboarding: %{ip: ip, port: port, uuid: Ecto.UUID.generate()}})

    :httpc.request(
      :post,
      {'http://localhost:4000/api/v1/onboarding', [], 'application/json', params},
      [],
      []
    )
  end
end
