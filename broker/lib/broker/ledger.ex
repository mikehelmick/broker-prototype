defmodule Broker.Ledger do
  use GenServer

  # GenServer state is a map of
  # EventID is the tuple of {type, source, id}
  # types -> {eventType -> [EventID]}
  # events -> {EventId -> event}
  # children -> %{{type, source, id} -> %{trigger -> EventID}}
  #   children = {{trigger, [{type, source, id}]}}

  def start_link(_opts \\ []) do
    state = {Map.new(), Map.new(), Map.new()}
    GenServer.start_link(__MODULE__, state, name: Ledger)
  end

  def init(args) do
    {%{}, %{}, %{}} = args
    {:ok, args}
  end

  def handle_call({:events_by_type, type}, _from, {types, events, children}) do
    rtn_events = Map.get(types, type)
    {:reply, rtn_events, {types, events, children}}
  end

  def handle_call({:get_event, eid = {_type, _source, _id}}, _from, {types, events, children}) do
    event = Map.get(events, eid)
    {:reply, event, {types, events, children}}
  end

  def handle_call({:get_children, eid = {_type, _source, _id}}, _from, {types, events, children}) do
    rtn_children = Map.get(children, eid)
    {:reply, rtn_children, {types, events, children}}
  end

  def handle_cast({:add_child, parentEventId, trigger}, {types, events, children}) do
    children = record_children(children, parentEventId, trigger, [])
    IO.puts("LEDGER\n#{inspect types}\n#{inspect events}\n#{inspect children}")
    {:noreply, {types, events, children}}
  end
  def handle_cast({:add_child, parentEventId, trigger, replies}, {types, events, children}) when is_list(replies) do
    # Record that trigger was run and event ID of what was returned.
    children = record_children(children, parentEventId, trigger, replies)
    IO.puts("LEDGER\n#{inspect types}\n#{inspect events}\n#{inspect children}")
    {:noreply, {types, events, children}}
  end

  def handle_cast({:record, event}, {types, events, children}) do
    type = CloudEvent.type(event)
    source = CloudEvent.source(event)
    id = CloudEvent.id(event)

    ensure_key(types, type, [])
    {_, types} = Map.get_and_update(types, type,
      fn
        nil -> {nil, [{type, source, id}]}
        list -> {list, list ++ [{type, source, id}]}
      end)
    events = Map.put(events, {type, source, id}, event)
    children = ensure_key(children, {type, source, id}, %{})

    IO.puts("LEDGER\n#{inspect types}\n#{inspect events}\n#{inspect children}")
    {:noreply, {types, events, children}}
  end

  defp ensure_key(map, key, default) do
    case Map.get(map, key) do
      nil -> Map.put(map, key, default)
      _ -> map
    end
  end

  defp record_children(children, parentEventId, trigger, events) when is_list(events) do
    children = ensure_key(children, parentEventId, %{})
    childEntry = Map.get(children, parentEventId)
      |> ensure_key(trigger, [])
    childEventIdList = Map.get(childEntry, trigger)
      |> add_child_event_ids(events)
    # Put this all back in.
    Map.put(children, parentEventId, Map.put(childEntry, trigger, childEventIdList))
  end

  defp add_child_event_ids(list, []), do: list
  defp add_child_event_ids(list, [event | rest]) do
    add_child_event_ids(
        list ++ [{CloudEvent.type(event), CloudEvent.source(event), CloudEvent.id(event)}],
        rest)
  end

end
