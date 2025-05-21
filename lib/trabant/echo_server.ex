defmodule Trabant.EchoServer do
  require Logger

  def init(options) do
    {:ok, options}
  end

  # def handle_in({"echo_server.ping", [opcode: :text]}, state) do
  #   # text = [opcode: :text]
  #   Logger.info("pong!")
  #   {:reply, :ok, {:text, "echo_server.pong"}, state}
  # end

  # def handle_in({"echo_server.bla", [opcode: :text]}, state) do
  #   Logger.info("BLA!")
  #   {:reply, :ok, {:text, "echo_server.bla"}, state}
  # end

  # def handle_in({"echo_server.click", [opcode: :text]}, state) do
  #   Logger.info("Click")
  #   Logger.info(state)
  #   {:reply, :ok, {:text, "echo_server.click:1"}, state}
  # end

  # def handle_in({"trabant.exec_js", [opcode: :text]}, state) do
  #   Logger.info("exec js")
  #   Logger.info(state)
  #   {:reply, :ok, {:text, "trabant.exec_js"}, state}
  # end

  def handle_in({json, [opcode: :text]}, state) do
    payload = Jason.decode!(json)
    message = payload["data"]["message"]
    Logger.info(message)
    payload = %{data: %{message: message <> " from the Elixir"}}
    json = Jason.encode!(payload)
    {:reply, :ok, {:text, json}, state}
  end

  def handle_in({:timeout, [opcode: :text]}, state) do
    Logger.info("timeout")
    {:reply, :ok, {:text, "echo_server.timeout"}, state}
  end

  def terminate(:timeout, state) do
    Logger.info("timeout from terminate")
    {:ok, state}
  end

  def terminate(_, state) do
    Logger.info("timeout from terminate with _")
    {:ok, state}
  end
end
