defmodule BrokerWeb.EventView do
  use BrokerWeb, :view

  def render("login_pii_scrubber.json", %{reply: reply}), do: reply
  def render("send_email.json", %{reply: reply}), do: reply
  def render("login_accounting.json", %{reply: reply}), do: reply
  def render("experiment_a.json", %{reply: reply}), do: reply

end
