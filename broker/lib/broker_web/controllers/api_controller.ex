defmodule BrokerWeb.ApiController do
  use BrokerWeb, :controller

  def emit(conn, params) do
    GenServer.cast(BrokerServer, {:emit, params})
    render conn, "emit.json", event: params
  end

  def add_type(conn, params) do
    GenServer.cast(BrokerServer, {:add_type, params["type"]})
    render conn, "add_type.json",
        type: params["type"]
  end

  def set_trigger(conn, params) do
    GenServer.cast(BrokerServer, {:set_trigger, params})
    render conn, "set_trigger.json", trigger: params
  end

  def list_triggers(conn, _params) do
    triggers = GenServer.call(BrokerServer, {:get_triggers})
    render conn, "list_triggers.json", triggers: triggers
  end

  def list_types(conn, _params) do
    types = GenServer.call(BrokerServer, {:list_types})
    render conn, "list_types.json", types: types
  end
end
