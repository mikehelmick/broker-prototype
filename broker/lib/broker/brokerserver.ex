defmodule Broker.BrokerServer do
  use GenServer

  # GenServer state is
  # {types, triggers, stats}
  # Types is [string]
  # Triggers is [{type, source, destination}]
  # Stats is %{{type,source} -> {enqueue, delivered, dropped}}

  def start_link(_opts \\ []) do
    state = {[], [], Map.new()}
    GenServer.start_link(__MODULE__, state, name: BrokerServer)
  end

  def init(args) do
    {[], [], %{}} = args
    {:ok, args}
  end

  def handle_cast({:add_type, type}, {types, triggers, stats}) do
    {:noreply, {types ++ [type], triggers, stats}}
  end

  # Async handling of an emit of a new event.
  # Depending on triggers configured, it will be routed to the correct place.
  def handle_cast(
      {:emit, event = %{"type" => type, "source" => source}},
      {types, triggers, stats}) do
    GenServer.cast(Ledger, {:record, event})
    # Non linked spawn
    IO.puts("BrokerServer:emit(Cast) #{inspect event}")
    spawn fn -> Invoker.invoke(triggers, event) end

    stats = stats_add_enqueue(stats, type, source)
    {:noreply, {types, triggers, stats}}
  end

  def handle_cast(
      {:set_trigger, trigger},
      {types, triggers, stats}) do
    IO.puts("BrokerServer:set_trigger #{inspect trigger}}")
    {:noreply, {types, triggers ++ [trigger], stats}}
  end

  def handle_cast({:add_dropped, type, source},
                  {types, triggers, stats}) do
    stats = stats_add_dropped(stats, type, source)
    {:noreply, {types, triggers, stats}}
  end

  def handle_cast({:add_delivered, type, source},
                  {types, triggers, stats}) do
    stats = stats_add_delivered(stats, type, source)
    {:noreply, {types, triggers, stats}}
  end

  def handle_call({:list_types}, _from, {types, triggers, stats}) do
    {:reply, types, {types, triggers, stats}}
  end

  def handle_call({:get_stats}, _from, {types, triggers, stats}) do
    {:reply, stats, {types, triggers, stats}}
  end

  def handle_call({:get_triggers}, _from, {types, triggers, stats}) do
    {:reply, triggers, {types, triggers, stats}}
  end


  # Private functions for delivery and helping with accounting.
  defp get_stats(stats, type, source) when is_map(stats) do
    case Map.get(stats, {type, source}) do
      {enqueued, delivered, dropped} -> {enqueued, delivered, dropped}
      _ -> {0, 0, 0}
    end
  end

  defp stats_add_enqueue(stats, type, source) when is_map(stats) do
    {enqueued, delivered, dropped} = get_stats(stats, type, source)
    Map.put(stats, {type, source}, {enqueued + 1, delivered, dropped})
  end

  defp stats_add_delivered(stats, type, source) when is_map(stats) do
    {enqueued, delivered, dropped} = get_stats(stats, type, source)
    Map.put(stats, {type, source}, {enqueued, delivered + 1, dropped})
  end

  defp stats_add_dropped(stats, type, source) when is_map(stats) do
    {enqueued, delivered, dropped} = get_stats(stats, type, source)
    Map.put(stats, {type, source}, {enqueued, delivered, dropped + 1})
  end
end
