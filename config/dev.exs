use Mix.Config

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :google_maps,
  url: "https://maps.googleapis.com/maps/api/",
  api_key: "AIzaSyBZHI1uYQ_cp0slrSo23y8zwIhh2yWXN04"
