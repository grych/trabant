defmodule Trabant.Router do
  use Plug.Router
  require Logger

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/" do
    conn = conn |> Plug.Conn.assign(:to_do, "2 + 2")
    # Logger.info(conn.assigns)
    send_resp(
      conn,
      200,
      EEx.eval_file("lib/html/index.html.eex", [abc1: "DEF", assigns: conn.assigns],
        engine: Trabant.LiveEngine
      )
    )
  end

  get "/websocket" do
    # conn = conn |> Plug.Conn.assign(:abc, "ABC")
    # Logger.info(conn)
    conn
    |> WebSockAdapter.upgrade(Trabant, [], timeout: 1000 * 60 * 60 * 24, compress: true)
    |> halt()
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
