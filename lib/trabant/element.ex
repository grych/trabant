defmodule Trabant.Element do
  require Logger

  def query(socket, selector) do
    {:ok, output} = Trabant.Core.exec_js(socket, "Trabant.query(\"#{selector}\");")
    Jason.decode(output)
  end

  def set_prop(socket, selector, properties) when is_list(properties) do
    properties = properties |> Map.new
    Trabant.Core.exec_js(socket, set_js(selector, properties))
  end

  def set_prop(socket, selector, properties) when is_map(properties) do
    Trabant.Core.exec_js(socket, set_js(selector, properties))
  end

  defp set_js(selector, properties) do
    "Trabant.set_prop(#{Trabant.encode_js(selector)}, #{Trabant.encode_js(properties)})"
  end

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
