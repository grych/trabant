defmodule Trabant.Live do
  def peek(socket, assign) do
    # .assigns
    assigns = socket.conn.assigns
    # IO.inspect(assign)
    # {result, binding} = Code.eval_quoted()
    # IO.inspect(Trabant.Amperes.get(assigns.__trabant_file_name))

    assigns = Trabant.Amperes.get(assigns.__trabant_file_name)

    amperes =
      for a <- assigns, Enum.member?(a.assigns, assign) do
        a.ampere
      end

    # IO.inspect(amperes)

    # TODO: if there is a new, check it and do it something with it
    ampere = List.first(amperes)
    js = ~s<Trabant.get_peek("#{ampere}")>
    # IO.inspect(js)
    result = Trabant.Core.exec_js(socket, js)
    # IO.inspect(result)
    {:ok, result}
  end
end
