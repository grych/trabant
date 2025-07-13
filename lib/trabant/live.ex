defmodule Trabant.Live do
  def peek(socket, assign) when is_atom(assign) do
    peek(socket, Atom.to_string(assign))
  end

  def peek(socket, assign) when is_binary(assign) do
    # .assigns
    # assigns = socket.conn.assigns
    # IO.inspect(assigns)
    # {result, binding} = Code.eval_quoted()
    # IO.inspect(Trabant.Amperes.get(assigns.__trabant_file_name))

    # assigns = Trabant.Amperes.get(assigns.__trabant_file_name)

    # amperes =
    #   for a <- assigns, Enum.member?(a.assigns, assign) do
    #     a.ampere
    #   end

    # IO.inspect(amperes)

    # ampere = List.first(amperes)
    js = ~s<Trabant.get_peek("#{assign}")>
    # IO.inspect(js)
    result = Trabant.Core.exec_js(socket, js)
    # IO.inspect(result)
    case result do
      {:ok, nil} -> {:error, "There is no assigns called #{assign}"}
      _ -> {:ok, result}
    end
  end
end
