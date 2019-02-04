defmodule Broker.Ledger do
  use GenServer

  # GenServer state is a map of
  # EventID is the tuple of {type, source, id}
  # types -> {eventType -> [EventID]}
  # events -> {EventId -> event}
  # children -> {{type, source, id} -> %{trigger -> EventID}}
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

  def handle_cast({:add_child, trigger, child_event}, {types, events, children}) do
    # Record that trigger was run and event ID of what was returned.
    # The event ID
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
    children = ensure_key(children, {type, source, id}, [])

    IO.puts("LEDGER\n#{inspect types}\n#{inspect events}\n#{inspect children}")
    {:noreply, {types, events, children}}
  end

  defp ensure_key(map, key, default) do
    case Map.get(map, key) do
      nil -> Map.put(map, key, default)
      _ -> map
    end
  end
end
