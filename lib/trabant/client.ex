defmodule Trabant.Client do
  def run() do
    {:ok, file1} = File.read("lib/js/trabant.js")
    {:ok, file2} = File.read("lib/js/element.js")
    file1 <> "\r\n" <> file2
  end
end
