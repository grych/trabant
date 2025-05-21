defmodule Trabant do
  @moduledoc """
  Documentation for `Trabant`.
  """

  # use ThousandIsland.Handler

  require Logger

  @behaviour WebSock

  @impl true
  def init(_opts) do
    # |> Keyword.merge([pid: self()])
    socket = %Trabant.Socket{topic: "user:*", pid: self()}
    Logger.info("INIT: #{inspect(socket)}")
    # for broadcasting:
    # Keyword.get(socket, :topic))
    Phoenix.PubSub.subscribe(Trabant.PubSub, socket.topic)
    # Trabant.Core.start_link(socket)
    {:ok, socket}
  end

  @impl true
  def handle_in({json, [opcode: :text]}, socket) do
    # Logger.debug("socket in handle_in: #{inspect(socket)}")
    # Logger.error(json)
    {:ok, payload} = Jason.decode(json)
    # Logger.error(payload)
    func = payload["function"]

    cond do
      func == "return_exec_js" ->
        other_pid = :erlang.list_to_pid(payload["process_id"])
        Process.send(other_pid, payload["output"], [])
        {:ok, socket}

      func == "do_click" ->
        commander = payload["commander"]
        {:ok, params} = Jason.decode(payload["params"])

        string = String.split(commander, ".")

        func_name =
          string
          |> List.last()
          |> String.to_atom()

        # |> String.to_existing_atom()  # TODO
        module_name =
          string
          |> List.delete_at(-1)
          |> Module.concat()

        # running the commander
        spawn(module_name, func_name, [socket, params])

        # It will be the broadcasting, I will do it later
        # TODO
        # Phoenix.PubSub.broadcast(Trabant.PubSub, Keyword.get(socket, :topic), json)

        {:ok, socket}

      true ->
        {:error, :timeout}
    end
  end

  def handle_in({:timeout, [opcode: :text]}, socket) do
    Logger.info("timeout")
    {:reply, :ok, {:text, "timeout"}, socket}
  end

  @impl true
  # outside (to the browser)
  def handle_info({json, [opcode: :text]}, socket) do
    {:push, {:text, json}, socket}
    # {:ok, socket}
  end

  @impl true
  def terminate(:timeout, socket) do
    Logger.info("timeout from terminate")
    {:ok, socket}
  end

  def terminate(whatever, socket) do
    Logger.info("timeout from terminate with #{inspect(whatever)}")
    {:ok, socket}
  end

  def event_handler(original_module, function_name) do
    case String.split(function_name, ".") do
      [function] ->
        {original_module, String.to_existing_atom(function)}

      module_and_function ->
        module = module_and_function |> List.delete_at(-1) |> Module.safe_concat()

        unless Code.ensure_loaded?(module) do
          raise """
          module #{inspect(module)} does not exist.
          """
        end

        function = module_and_function |> List.last() |> String.to_existing_atom()
        {module, function}
    end
  end

  def encode_js(value), do: Jason.encode!(value)
end
