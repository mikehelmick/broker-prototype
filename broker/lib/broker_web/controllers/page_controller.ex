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

  def event(conn, params) do
    eventId = {params["type"], params["source"], params["id"]}

    topEvent = GenServer.call(Ledger, {:get_event, eventId})
    {eventCache, childMap} =
        load_events(Map.new(), Map.new(), [CloudEvent.child_context_tuple(topEvent)])

    IO.puts("#{inspect eventCache}\n#{inspect childMap}")

    render conn, "event.html",
        eventId: eventId, topEvent: topEvent,
        eventCache: eventCache, childMap: childMap
  end

  defp load_events(eventCache, childMap, []), do: {eventCache, childMap}
  defp load_events(eventCache, childMap, [eventId | rest]) do
    eventCache = Map.put(eventCache, eventId, GenServer.call(Ledger, {:get_event, eventId}))

    # Get children, this is a map of trigger to events it returned
    case GenServer.call(Ledger, {:get_children, eventId}) do
      nil -> load_events(eventCache, childMap, rest)
      children ->
        IO.puts("CHILDREN: #{inspect children}")
        childMap = Map.put(childMap, eventId, children)

        IO.puts("CHILD MAP: #{inspect childMap}")

        # Enqueue any events in the child map
        newEventIds = Enum.flat_map(Map.values(children),
            fn childEventId -> childEventId end)

        IO.puts("NEW EVENT IDS: #{inspect newEventIds}")

        load_events(eventCache, childMap, rest ++ newEventIds)
    end
  end

end
