import Config

config :trabant,
  http: [scheme: :http, port: 4000, ip: {127, 0, 0, 1}]

config :trabant,
  browser_timeout: 5_000

import_config "#{Mix.env()}.exs"
