defmodule LiveEngineTest do
  use ExUnit.Case
  require Logger
  require EEx

  test "just an assign" do
    assert EEx.eval_string("<%= @foo %>", [assigns: [foo: 1]], engine: Trabant.LiveEngine) == "1"
  end
end
