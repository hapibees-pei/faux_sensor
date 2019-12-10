defmodule FauxSensor.Gateway do
  use Agent
  require Logger

  alias FauxSensor.QrCode
  alias FauxSensor.Mqtt.Publish
  alias FauxSensor.TcpServer

  def init(ip, port) do
    TcpServer.start_link(ip, port)

    Agent.start_link(fn -> %{"count" => 0, "pids" => %{}, "ip" => nil, "port" => nil, "uuid" => nil} end,
      name: __MODULE__
    )

    send_request_create(ip, port)

    QrCode.generate(ip, port)
  end

  def add_sensor(pid) do
    Logger.info("Add sensor")

    #id = add_new_pid(uuid, state, pid)
    Agent.get_and_update(__MODULE__, &add_new_pid(&1, pid))
  end

  def set_internal_state(%{"uuid" => uuid} = internal) do
    Logger.info("Internal #{uuid}")
    Agent.update(__MODULE__, fn state -> Map.merge(state, internal) end)
    Publish.send_gateway_status(uuid)
  end

  def send_to_mqtt(sensor_pid, data) do
    {uuid, pids} =
      Agent.get(__MODULE__, fn %{"uuid" => uuid, "pids" => pids} = _state -> {uuid, pids} end)

    id = pids[sensor_pid]
    Logger.info("Sent to mqtt")
    Publish.send_data(uuid, id, data)
  end

  def send_request_create(ip, port) do
    Application.ensure_all_started(:inets)

    {:ok, params} = Jason.encode(%{onboarding: %{"ip" => ip, "port" => port, "uuid" => Ecto.UUID.generate()}})

    :httpc.request(
      :post,
      {'http://localhost:4000/api/v1/onboarding', [], 'application/json', params},
      [],
      []
    )
  end

  def add_new_pid(%{"uuid" => nil} = state, _pid) do
    {-1, state}
  end

  def add_new_pid(state, pid) do
    count = state["count"]
    pids = state["pids"]
    uuid =  state["uuid"]
    new_pids = Map.put(pids, pid, count) #%{pids | IO.inspect(pid) => count}
    new_count = count + 1
    new_state = %{state | "pids" => new_pids, "count" => new_count}
    Publish.send_sensor_status(uuid, new_count)
    {new_count, new_state}
    #Agent.update(__MODULE__, fn _state -> new_state end)
    #count
  end
end
