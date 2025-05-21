defmodule TrabantTest do
  use ExUnit.Case
  doctest Trabant
  require Logger
  #   {:ok, pid} = TrabantTestApp.WebsocketClient.start_link(debug: [:trace])
  #   {:ok, json} = Trabant.Core.exec_js(%Trabant.Socket{pid: self()}, "2+2")
  #   refute json == "2+2"
  # end
end
