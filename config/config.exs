import Config

config :trabant,
  http: [port: 4000]

config :trabant,
  browser_timeout: 5_000

import_config "#{Mix.env()}.exs"
