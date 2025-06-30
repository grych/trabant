defmodule Trabant.Application do
  # See https://hexdocs.pm/elixir/Application.htmlApplication.start(:
  # for more information on OTP Applications
  @moduledoc false
  require Logger

  use Application

  def start(_type, _args) do
    trabant_http = Application.fetch_env!(:trabant, :http)

    trabant_host_ip =
      case :inet.getaddr(to_charlist(trabant_http[:host]), :inet) do
        {:ok, host_ip} -> host_ip
        {:error, _} -> trabant_http[:ip]
      end

    # List all child processes to be supervised
    children = [
      {Bandit,
       plug: Trabant.Router,
       scheme: trabant_http[:scheme],
       ip: trabant_host_ip,
       port: trabant_http[:port]},
      {Phoenix.PubSub, name: Trabant.PubSub},
      {CubDB, data_dir: "db/database.cubdb", name: :db}
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
