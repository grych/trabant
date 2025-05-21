defmodule Trabant.Core do
  # use GenServer
  require Logger

  # def start_link(socket) do
  #   GenServer.start_link(__MODULE__, %Trabant.Core{
  #     socket: socket
  #   })
  # end

  # def init(state) do
  #   Process.flag(:trap_exit, true)
  #   {:ok, state}
  # end

  def exec_js(socket, js) do
    # Logger.debug("    SOCKET in exec_js: #{inspect(socket)}")
    json = Jason.encode!(js)
    # Keyword.get(socket, :pid)
    transport_pid = socket.pid

    Process.send(
      transport_pid,
      {Jason.encode!(%{
         function: "exec_js",
         output: json,
         process_id: :erlang.pid_to_list(self())
       }), [opcode: :text]},
      []
    )

    receive do
      # Logger.debug(json)
      json ->
        {:ok, json}
    after
      Application.fetch_env!(:trabant, :browser_timeout) ->
        {:error}
        # 5_000 -> {:error}
    end
  end
end
