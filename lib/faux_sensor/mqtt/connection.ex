defmodule FauxSensor.Mqtt.Connection do
  # TODO: Change to DynamicSupervisor
  use Supervisor
  alias FauxSensor.Mqtt.Handler

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(opts \\ %{}) do
    config = Map.merge(default_config(), opts)

    children = [
      {Tortoise.Connection,
       [
         client_id: config.client_id,
         server: {Tortoise.Transport.Tcp, host: config.host, port: config.port},
         user_name: config.user_name,
         password: config.password,
         handler: {Handler, []},
         keep_alive: 600
       ]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def subscriptions(gateway_id) do
    "gateway/#{gateway_id}"
  end

  def default_config do
    %{
      client_id: "faux",
      host: "10.0.2.38",
      port: 1883,
      user_name: "guest",
      password: "guest",
      keep_alive: 600
    }
  end
end
