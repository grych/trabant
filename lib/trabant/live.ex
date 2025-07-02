defmodule Trabant.Live do
  def peek(socket, _assign) do
    # .assigns
    assigns = socket.conn
    IO.inspect(assigns)
    # {result, binding} = Code.eval_quoted()
  end
end
