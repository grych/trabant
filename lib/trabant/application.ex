defmodule Trabant.Application do
  # See https://hexdocs.pm/elixir/Application.htmlApplication.start(:
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    trabant_http = Application.fetch_env!(:trabant, :http)
    children = [
      {Bandit, plug: Trabant.Router,
        scheme: trabant_http[:scheme],
        ip: trabant_http[:ip],
        port: trabant_http[:port]
      },
      {Phoenix.PubSub, name: Trabant.PubSub}
      #  Registry.child_spec(
      #   keys: :duplicate,
      #   name: Registry.MyWebsocketApp
      # )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Trabant.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
