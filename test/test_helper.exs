# Application.ensure_all_started(:hound)
Bandit.start_link(plug: TrabantTestApp.Router, port: 4567)
ExUnit.start()
