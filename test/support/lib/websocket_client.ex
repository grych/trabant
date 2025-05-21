defmodule TrabantTestApp.WebsocketClient do
  use WebSockex
  require Logger

  def start_link(opts \\ []) do
    # WebSockex.start_link("wss://echo.websocket.org/?encoding=text", __MODULE__, :fake_state, opts)
    WebSockex.start_link("ws://localhost:4567/websocket", __MODULE__, :fake_state, opts)
  end

  # def echo(client, message) do
  #   Logger.info("Sending message: #{message}")
  #   WebSockex.send_frame(client, {:text, message})
  # end

  def handle_connect(_conn, socket) do
    # Logger.info("Connected!")
    {:ok, socket}
  end

  # def handle_frame({:text, "Can you please reply yourself?" = msg}, :fake_state) do
  #   Logger.info("Received Message: #{msg}")
  #   msg = "Sure can!"
  #   Logger.info("Sending message: #{msg}")
  #   {:reply, {:text, msg}, :fake_state}
  # end
  # def handle_frame({:text, "Close the things!" = msg}, :fake_state) do
  #   Logger.info("Received Message: #{msg}")
  #   {:close, :fake_state}
  # end
  # def handle_frame({:text, msg}, :fake_state) do
  #   Logger.info("Received Message: #{msg}")
  #   {:ok, :fake_state}
  # end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect(reason)}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end

  def handle_info({json, [opcode: :text]}, socket) do
    # Logger.debug(inspect(Jason.decode!(json)))
    payload = Jason.decode!(json)
    other_pid = :erlang.list_to_pid(payload["process_id"])
    Process.send(other_pid, payload["output"], [])
    {:ok, socket}
  end
end
