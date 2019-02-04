defmodule BrokerWeb.ApiView do
  use BrokerWeb, :view

  def render("add_type.json", %{type: type}) do
    %{type: type}
  end

  def render("list_types.json", %{types: types}) do
    types
  end

  def render("emit.json", %{event: event}) do
    %{id: CloudEvent.id(event)}
  end

  def render("set_trigger.json", %{trigger: trigger}) do
    trigger
  end

  def render("list_triggers.json", %{triggers: triggers}) do
    triggers
  end
end
