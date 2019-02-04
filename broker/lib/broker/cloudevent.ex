# Utility methods for extracting parts of a CloudEvent
# when stored as a Elixir map.
defmodule CloudEvent do
  def current_version(), do: "0.2"

  # methods for extracting parts of a cloud event
  # Optional fields return nil atom if not present
  def type(%{"type" => type}), do: type

  def specversion(%{"specversion" => version}), do: version

  def source(%{"source" => source}), do: source

  def id(%{"id" => id}), do: id

  def time(%{"time" => time}), do: time
  def time(_), do: nil

  def schemaurl(%{"schemaurl" => url}), do: url
  def schemaurl(_), do: nil

  def content_type(%{"contenttype" => contenttype}), do: contenttype
  def content_type(_), do: nil

  def data(%{"data" => data}), do: data
  def data(_), do: nil

  def extension(event, extension) when is_map(event) do
    Map.get(event, extension)
  end

  def context(event), do: extension(event, "knative:context")

  def child_context(%{"type" => type, "source" => source, "id" => id}) do
    [type, source, id]
  end

  # Methods for build a cloud event up.
  # Set up for chainging
  # CloudEvent.new() |> CloudEvent.type("foo") |> CloudEvent.source("bar")
  def new(), do: Map.new() |> default_version()
  def type(event, type) when is_map(event), do: Map.put(event, "type", type)
  def specversion(event, version) when is_map(event), do: Map.put(event, "specversion", version)
  def default_version(event) when is_map(event), do: specversion(event, current_version())
  def source(event, source) when is_map(event), do: Map.put(event, "source", source)
  def id(event, id) when is_map(event), do: Map.put(event, "id", id)
  def time(event, time) when is_map(event), do: Map.put(event, "time", time)
  def schemaurl(event, url) when is_map(event), do: Map.put(event, "schemaurl", url)
  def content_type(event, ctype) when is_map(event), do: Map.put(event, "contentype", ctype)
  def data(event, data) when is_map(event), do: Map.put(event, "data", data)
  def extension(event, extension, value) when is_map(event) do
    Map.put(event, extension, value)
  end
  def context(event, context) when is_map(event) do
    # TODO: validate context tuple format {type, source, id}
    Map.put(event, "knative:context", context)
  end
end
