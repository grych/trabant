defmodule CoreTest do
  use ExUnit.Case, async: true
  alias Trabant.Core
  doctest Trabant.Core
  require Logger

  setup do
    {:ok, pid} = TrabantTestApp.WebsocketClient.start_link(debug: [:trace])
    {:ok, pid: pid}
  end

  test "exec_js", %{pid: pid} = _context do
    # {:ok, pid} = TrabantTestApp.WebsocketClient.start_link(debug: [:trace])
    {:ok, json} = Core.exec_js(%Trabant.Socket{pid: pid}, "2+2")
    assert Jason.decode!(json) == "2+2"
  end

  # test "bad exec_js" do # ???????? TODO
end
