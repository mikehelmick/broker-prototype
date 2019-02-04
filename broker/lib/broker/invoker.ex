defmodule Invoker do

  def invoke(triggers, event) do
    IO.puts("Invoke was called for #{inspect event} \n triggers: #{inspect triggers}")
    fan_out_invoke(triggers, event, 0)
  end

  # No rules matched, event is dropped
  defp fan_out_invoke([], event, 0) do
    GenServer.cast(BrokerServer,
        {:add_dropped, CloudEvent.type(event), CloudEvent.source(event)})
  end
  defp fan_out_invoke([], _event, _matches) do
  end
  # Trigger source/type matches event source/type, spawn an invoke.
  defp fan_out_invoke([trigger | triggers], event, matches) do
    trigger_type = trigger["type"]
    trigger_source = trigger["source"]
    destination = trigger["destination"]
    event_type = CloudEvent.type(event)
    event_source = CloudEvent.source(event)
    case {trigger_type, trigger_source, event_type, event_source} do
      {x, y, x, y} ->
        spawn fn -> do_invoke(event, destination) end
        fan_out_invoke(triggers, event, matches + 1)
      {x, "", x, _} ->
        spawn fn -> do_invoke(event, destination) end
        fan_out_invoke(triggers, event, matches + 1)
      _ ->
        fan_out_invoke(triggers, event, matches)
    end
  end

  def do_invoke(event, destination) do
    IO.puts("sending #{destination} event: #{inspect event}")
    type = CloudEvent.type(event)
    source = CloudEvent.source(event)

    encoded_event = Jason.encode!(event)

    # Make HTTP Post request to destionation
    case HTTPoison.post(destination, encoded_event, [{"Content-Type", "application/json"}]) do
      {:ok, results} ->
        # If there are any cloud event records in the response,
        # Add context of the source Event
        # Put them back on the broker
        reply = Jason.decode!(results.body)
        IO.puts("got reply #{inspect reply}")
        handle_reply(event, destination, reply)

        # Do the accounting.
        GenServer.cast(BrokerServer, {:add_delivered, type, source})

      _ ->
        # Error handling for the lazy...
        IO.puts("Failure deliving event.")
    end
  end

  defp maybe_add_source(event = %{"source": nil}, dest) do
    CloudEvent.source(event, dest)
  end
  defp maybe_add_source(event, _), do: event

  # single event
  defp handle_reply(_event, _destination, reply) when reply == %{} do
    # Reply was empty
  end
  defp handle_reply(event, destination, reply) when is_map(reply) do
    new_event = reply
      |> maybe_add_source(destination)
      |> CloudEvent.context(CloudEvent.child_context(event))
    GenServer.cast(BrokerServer, {:emit, new_event})
  end
  defp handle_reply(_event, _destination, []) do
  end
  defp handle_reply(event, destination, [reply | rest]) do
    handle_reply(event, destination, reply)
    handle_reply(event, destination, rest)
  end
end
