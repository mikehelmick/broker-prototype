defmodule Trigger do
  # Type is the Type of the cloud environment
  # Source is an optional source filter
  # Destionation is required delivery address
  @enforce_keys [:type, :destination]
  defstruct [:type, :source, :destination]

  def type(trigger = %{type: type}) when is_map(trigger), do: type
  def source(trigger = %{source: source}) when is_map(trigger), do: source
  def destination(trigger= %{destination: dest}) when is_map(trigger), do: dest
end
