defmodule Trabant.Client do
  def run() do
    {:ok, file1} = File.read("lib/js/trabant.js")
    {:ok, file2} = File.read("lib/js/element.js")
    {:ok, file3} = File.read("lib/js/live.js")
    file1 <> "\r\n" <> file2 <> "\r\n" <> file3
  end
end
