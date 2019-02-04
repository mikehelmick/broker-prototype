defmodule BrokerWeb.EventController do
  use BrokerWeb, :controller

  defp build_event(source, type, id, data) do
    CloudEvent.new()
     |> CloudEvent.type(type)
     |> CloudEvent.source(source)
     |> CloudEvent.id(id)
     |> CloudEvent.time(DateTime.utc_now() |> DateTime.to_iso8601())
     |> CloudEvent.content_type("application/json")
     |> CloudEvent.data(data)
  end

  def login_pii_scrubber(conn, params) do
    IO.puts("login_pii_scrubber: #{inspect params}")

    data = CloudEvent.data(params)
    scrubbed = %{}
    scrubbed =
      case data["age"] do
        x when x < 18 -> Map.put(scrubbed, "age_range", "< 18")
        x when x >= 18 and x < 30 -> Map.put(scrubbed, "age_range", "18-30")
        x when x >= 30 and x < 40 -> Map.put(scrubbed, "age_range", "30-40")
        _ -> Map.put(scrubbed, "age_range", ">= 40")
      end
    scrubbed = Map.put(scrubbed, "country", "USA")

    event = build_event("LoginPIIScrubber", "LoginNoPII",
        "#{CloudEvent.type(params)}-#{CloudEvent.source(params)}-#{CloudEvent.id(params)}",
        scrubbed)

    render conn, "login_pii_scrubber.json", reply: event
  end

  def send_email(conn, params) do
    # In the prototype, this doesn't do anything.
    data = CloudEvent.data(params)
    email = data["email"]

    event = build_event("SendEmail", "EmailSentEvent",
        "#{CloudEvent.type(params)}-#{CloudEvent.source(params)}-#{CloudEvent.id(params)}",
        %{"email": email, "success": true})

    render conn, "send_email.json", reply: event
  end

  def login_accounting(conn, _params) do
    # In the prototype, this doesn't do anything.
    render conn, "login_accounting.json", reply: %{}
  end

  def experiment_a(conn, params) do

    event1 = build_event("ExperimentA", "ExpResult1",
        "#{CloudEvent.type(params)}-#{CloudEvent.source(params)}-#{CloudEvent.id(params)}",
        %{"resultA": "positive"})
    event2 = build_event("ExperimentA", "ExpResult2",
        "#{CloudEvent.type(params)}-#{CloudEvent.source(params)}-#{CloudEvent.id(params)}",
        %{"resultB": "negative"})

    render conn, "experiment_a.json", reply: [event1, event2]
  end

  def experiment_b(conn, _params) do
    # No output from experiment B
    render conn, "experiment_b.json", reply: %{}
  end

end
