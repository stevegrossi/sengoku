import Config

config :sengoku, SengokuWeb.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}],
  url: [host: "www.playsengoku.com", port: 443]

config :sengoku, Sengoku.Repo,
  url: System.fetch_env!("DATABASE_URL")
