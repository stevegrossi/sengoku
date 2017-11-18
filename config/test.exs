use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sengoku, SengokuWeb.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Take screenshot on failed browser test case
config :wallaby, screenshot_on_failure: true
