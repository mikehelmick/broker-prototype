defmodule Demo do

  def setup_demo() do
    EventClient.add_type("login")

    EventClient.add_trigger("login", "LoginService",
        "http://localhost:4000/deliver/login_pii_scrubber")
    EventClient.add_trigger("login", "LoginService",
        "http://localhost:4000/deliver/send_email")

    EventClient.add_type("LoginNoPII")

    EventClient.add_trigger("LoginNoPII", "LoginPIIScrubber",
        "http://localhost:4000/deliver/login_accounting")

    EventClient.add_trigger("LoginNoPII", "",
        "http://localhost:4000/deliver/experiment_a")

    # EventClient.add_type("EmailSentEvent")
    # We're not going to register this one, it should be auto
    # registered in the broker in invocation of the send_email service

    EventClient.add_type("ExpResult1")
    EventClient.add_type("ExpResult2")

    EventClient.add_trigger("ExpResult1", "ExperimentA",
        "http://localhost:4000/deliver/experiment_b")
  end


  def send_login_event(id, name, email, age, city) do
    EventClient.send_event(
        "LoginService", "login", id,
        %{"name": name,
          "email": email,
          "age": age,
          "city": city})
  end
end
