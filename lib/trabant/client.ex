defmodule Trabant.Client do
  def run() do
    {:ok, file1} = File.read("lib/ts/trabant.js")
    {:ok, file2} = File.read("lib/ts/element.js")
    {:ok, file3} = File.read("lib/ts/live.js")
    file1 <> "\r\n" <> file2 <> "\r\n" <> file3
  end
end
