defmodule Trabant.LiveEngineTest do
  use ExUnit.Case
  require Logger
  require EEx

  test "just an assign" do
    assert EEx.eval_string("<span><%= @foo %></span>", [assigns: [foo: 1]], engine: Trabant.LiveEngine) == "<span trabant_ampere=\"geztmmrxgu4danzv\">1</span>"
  end
end
