defmodule Trabant.Element do
  require Logger

  def query(socket, selector) do
    {:ok, output} = Trabant.Core.exec_js(socket, "Trabant.query(\"#{selector}\");")
    Jason.decode(output)
  end

  @doc """
  Finds all html elements using `selector` and sets their properties.

  Takes a map or keyword list of properties to be set, where the key is a property name and
  the value is the new value to be set. If the property is a Javascript object (like `style`
  or `attributes`), it expects a map.

  Returns tuple `{:ok, number}` with number of updated elements or `{:error, description}`.

  Examples:

      iex> set_prop socket, "a", %{"attributes" => %{"class" => "btn btn-warning"}}
      {:ok, 1}

      iex> set_prop socket, "button", style: %{"backgroundColor" => "red", "width" => "200px"}
      {:ok, 1}

      iex> set_prop socket, "div", innerHTML: "updated"
      {:ok, 3}

  You may store any JS encodable value in the property:

      iex> set_prop socket, "#button1", custom: %{example: [1, 2, 3]}
      {:ok, 1}
      iex> query_one socket, "#button1", :custom
      {:ok, %{"custom" => %{"example" => [1, 2, 3]}}}

  The value of the property may be either a string, or a safe html. It is recommended to use
  safe html in case of using values from outside the application, like user inputs.

      set_prop socket, "#div1", value: ~E/<%=first_name%> <%=last_name%>/
  """
  def set_prop(socket, selector, properties) when is_list(properties) do
    properties = properties |> Map.new()
    Trabant.Core.exec_js(socket, set_js(selector, properties))
  end

  def set_prop(socket, selector, properties) when is_map(properties) do
    Trabant.Core.exec_js(socket, set_js(selector, properties))
  end

  defp set_js(selector, properties) do
    "Trabant.set_prop(#{Trabant.encode_js(selector)}, #{Trabant.encode_js(properties)})"
  end

  @doc """
  Get properties for the selector in the browser and collects found element properties.
  `property_or_properties_list` specifies what properties will be returned. It may either be
  a string, an atom or a list of strings or atoms.

  Returns:

  * `{:ok, map}` - where the `map` contains queried elements.

    The keys are selectors which clearly identify the element: if the object has an `id`
    declared - a string of `"#id"`, otherwise Drab declares the `drab-id` attribute and the
    key became `"[drab-id='...']"`.

    Values of the map are maps of `%{property => property_value}`. Notice that for some properties
    (like `style` or `dataset`), the property_value is a map as well.

  * `{:error, message}` - the browser could not be queried

  Examples:
      iex> get_prop socket, "button", :clientWidth
      {:ok, %{"#button1" => %{"clientWidth" => 66}}}

      iex(170)> get_prop socket, "div", :id
      {:ok,
       %{"#begin" => %{"id" => "begin"}, "#drab_pid" => %{"id" => "drab_pid"},
         "[drab-id='472a5f90-c5cf-434b-bdf1-7ee236d67938']" => %{"id" => ""}}}

      iex> get_prop socket, "button", ["dataset", "clientWidth"]
      {:ok,
       %{"#button1" => %{"clientWidth" => 66,
           "dataset" => %{"d1" => "[1,2,3]", "d1x" => "[1,2,3]", "d2" => "[1, 2]",
             "d3" => "d3"}}}}

  """
  def get_prop(socket, selector, property_or_properties_list)

  def get_prop(socket, selector, property) when is_binary(property) or is_atom(property) do
    get_prop(socket, selector, [property])
  end

  def get_prop(socket, selector, properties) when is_list(properties) do
    Trabant.Core.exec_js(socket, get_js(selector, properties))
  end

  defp get_js(selector, properties) do
    "Trabant.get_prop(#{Trabant.encode_js(selector)}, #{Trabant.encode_js(properties)})"
  end
end
