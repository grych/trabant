defmodule Trabant.Live do
  def peek(socket, assign) do
    # .assigns
    assigns = socket.conn.assigns
    IO.inspect(assign)
    # {result, binding} = Code.eval_quoted()
    IO.inspect(Trabant.Amperes.get(assigns.__trabant_file_name))
    {:ok, socket}
  end
end
