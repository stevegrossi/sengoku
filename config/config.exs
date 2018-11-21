# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :sengoku, SengokuWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QpHcO/4ZvVzgUmEQG94LGu/wc+KI8ggpDv00a0TTy6o6wyjqg5MZAcVzbiRFUC8e",
  render_errors: [view: SengokuWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Sengoku.PubSub, adapter: Phoenix.PubSub.PG2]

config :phoenix, :json_library, Poison

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
