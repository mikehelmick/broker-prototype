defmodule EventClient do

  def do_post(api, obj) do
    url = "http://localhost:4000/#{api}"
    body = Poison.encode!(obj)

    {:ok, results} = HTTPoison.post url, body, [{"Content-Type", "application/json"}]
    json = Poison.decode!(results.body)
    IO.puts(inspect json)
  end

  def do_get(api) do
    url = "http://localhost:4000/#{api}"

    {:ok, results} = HTTPoison.get url, [{"Content-Type", "application/json"}]
    json = Poison.decode!(results.body)
    IO.puts(inspect json)
  end

  def add_type(type) do
    do_post("api/add_type", %{type: type})
  end

  def list_types() do
    do_get("api/list_types")
  end

  def add_trigger(type, destination) do
    %Trigger{type: type, destination: destination}
      |> register_trigger()
  end

  def add_trigger(type, source, destination) do
    %Trigger{type: type, destination: destination, source: source}
      |> register_trigger()
  end

  def list_triggers() do
    do_get("api/list_triggers")
  end

  defp register_trigger(trigger) do
    IO.puts("Registering trigger: #{inspect trigger}")
    do_post("api/set_trigger", trigger)
  end

  def send_event(source, type, id, data) do
    event = CloudEvent.new()
      |> CloudEvent.type(type)
      |> CloudEvent.default_version()
      |> CloudEvent.source(source)
      |> CloudEvent.id(id)
      |> CloudEvent.time(DateTime.utc_now() |> DateTime.to_iso8601())
      |> CloudEvent.content_type("application/json")
      |> CloudEvent.data(data)
    IO.puts("Emitting cloud event: #{inspect event}")
    do_post("api/emit", event)
  end
end
