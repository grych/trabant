import Config

config :trabant,
  http: [scheme: :http, port: 4000, host: "localhost"]

config :trabant,
  browser_timeout: 5_000

import_config "#{Mix.env()}.exs"
