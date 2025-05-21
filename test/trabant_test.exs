defmodule TrabantTest do
  use ExUnit.Case
  doctest Trabant
  require Logger

  test "exec_js" do
    {:ok, pid} = TrabantTestApp.WebsocketClient.start_link(debug: [:trace])
    {:ok, json} = Trabant.Core.exec_js(%Trabant.Socket{pid: pid}, "2+2")
    assert Jason.decode!(json) == "2+2"
  end

  # test "bad exec_js" do # ???????? TODO
  #   {:ok, pid} = TrabantTestApp.WebsocketClient.start_link(debug: [:trace])
  #   {:ok, json} = Trabant.Core.exec_js(%Trabant.Socket{pid: self()}, "2+2")
  #   refute json == "2+2"
  # end
end
