defmodule BrokerWeb.PageController do
  use BrokerWeb, :controller

  def index(conn, _params) do
    stats = GenServer.call(BrokerServer, {:get_stats})
    types = GenServer.call(BrokerServer, {:list_types})
    triggers = GenServer.call(BrokerServer, {:get_triggers})

    render conn, "index.html", stats: stats, types: types,
        triggers: triggers
  end

  def events(conn, params) do
    type = params["type"]
    events = GenServer.call(Ledger, {:events_by_type, type})

    render conn, "events.html", events: events, type: type
  end
end
