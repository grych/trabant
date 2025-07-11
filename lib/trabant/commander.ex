defmodule Trabant.Commander do
  require Logger

  def on_open(socket, amperes) do
    # IO.inspect(amperes)
    # Logger.debug(inspect(amperes))
    conn = Plug.Conn.assign(socket.conn, :__trabant_amperes, amperes)
    socket = %{socket | conn: conn}
    # IO.inspect(socket.conn.assigns)
    assigns = Enum.filter(socket.conn.assigns,
      fn {x, _y} -> not String.starts_with?(Atom.to_string(x), "__")
    end)
    # IO.inspect(assigns)
    assigns = Enum.map(assigns, fn {x, y} -> [Atom.to_string(x), y] end)
    # IO.inspect(assigns)
    # assigns = Enum.filter(f,
    #   fn {x, _y} -> not String.starts_with?(Atom.to_string(x), "__")
    # end)
    amperes = for amperes <- socket.conn.assigns.__trabant_amperes, into: %{} do
      {amperes["ampere"],
        for as <- amperes["assigns"], into: %{} do
          {as, values_of_assings(assigns, as)}
        end
      }
    end
    # IO.inspect(amperes)
    {:ok, amperes} = Jason.encode(amperes)
    # IO.inspect(amperes)
    Trabant.Core.exec_js(socket, "Trabant.amperes = " <> amperes <> "; console.log(Trabant.amperes);")
    {:ok, socket}
  end

  defp values_of_assings(assigns, assign) do
    [_, value] = Enum.find(assigns, fn x -> List.first(x) == assign end)
    value
  end

  @spec find_in_sender(any(), any(), any()) :: {:error} | {:ok, any()}
  @doc """
  Search in sender for an sender_id (the id is created in HTML). Returns where.

  Returns:
    {:ok, value} - when the lenght of the sender returns 1
    {:error} - whenever it is not an 1

  iex> Commander.find_in_sender([%{"id" => "my-div","text" => "WHAT? 4","html" => "WHAT? 4 "}], "my-div", "text")
  {:ok, "WHAT? 4"}
  iex> Commander.find_in_sender([%{"id" => "my-div","text" => "WHAT? 4","html" => "WHAT? 4 "}], "wrong", "text")
  {:error}
  iex> Commander.find_in_sender([%{"id" => "my-div","text" => "WHAT? 4","html" => "WHAT? 4 "}], "input", "text")
  {:error}
  """
  def find_in_sender(sender, sender_id, where) do
    # Logger.debug(sender)
    par =
      Enum.filter(
        for x <- sender do
          if x["id"] == sender_id, do: x[where]
        end,
        fn x -> x end
      )

    case length(par) do
      1 -> {:ok, hd(par)}
      _ -> {:error}
    end

    # [par_first | _] = par
    # par_first
  end

  def button_click(socket, _sender) do
    {:ok, property} = Trabant.Element.get_prop(socket, "#input", :value)
    # Logger.debug("ONE AGAINA: #{inspect(property)}")
    {:ok, output} =
      Trabant.Core.exec_js(socket, "eval(" <> property["#input"]["value"] <> ");")

    {:ok, _value} = Trabant.Element.set_prop(socket, "#my-div", innerText: output)
    # Logger.debug("VALUE: #{inspect(value)}")

    # {:ok, value} = Trabant.Element.set_prop socket, "input", style: %{"backgroundColor" => "red", "width" => "200px"}
    # Logger.debug("VALUE: #{inspect(value)}")

    {:ok, get_peek} = Trabant.Live.peek(socket, :to_do)
    IO.inspect(get_peek)
    {:ok, socket}
  end
end
