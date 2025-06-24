defmodule Trabant.Commander do
  require Logger

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

    {:ok, socket}
  end
end
