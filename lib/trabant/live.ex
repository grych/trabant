defmodule Trabant.Live do
  def peek(socket, _assign) do
    file = socket.conn.assigns
    IO.inspect(file)
    # {result, binding} = Code.eval_quoted()
  end
end
