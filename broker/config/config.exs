# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :broker, BrokerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9ZzmpM4kR552Am7GhuZ9j1ZCszJ+Lt5j56lqS+FJ9JRfBbeLIOV+0rlwz1drp5op",
  render_errors: [view: BrokerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Broker.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
