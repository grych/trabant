defmodule TrabantTestApp.Router do
  use Plug.Router
  require Logger

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/" do
    conn = conn |> Plug.Conn.assign(:to_do, "2 + 2")

    send_resp(
      conn,
      200,
      EEx.eval_file("lib/html/index.html.eex", abc1: "DEF", assigns: conn.assigns)
    )

    # send_resp(conn, 200, "whatever")
  end

  get "/websocket" do
    conn
    |> WebSockAdapter.upgrade(Trabant, [topic: "user:*"],
      timeout: 1000 * 60 * 60 * 24,
      compress: true
    )
    |> halt()
  end
end
