defmodule Trabant.LiveEngineTest do
  use ExUnit.Case
  require Logger
  require EEx

  test "just an assign" do
    assert EEx.eval_string("<span><%= @foo %></span>", [assigns: [foo: 1]], engine: Trabant.LiveEngine) == "<span trabant_ampere=\"gm2toobxgiytsnjq\">1</span>"
  end

  test "assign with the one assigns" do
    assert EEx.eval_string("<span><%= @bar %></span>", [assigns: [bar: 2]], engine: Trabant.LiveEngine) == "<span trabant_ampere=\"gm2toobxgiytsnjq\">2</span>"
  end

  test "assign with the two assigns" do
    assert EEx.eval_string("<span><%= @bar %><span><%= @foo %></span></span>", [assigns: [foo: 1, bar: 2]], engine: Trabant.LiveEngine) == "<span trabant_ampere=\"gm2toobxgiytsnjq\">2<span trabant_ampere=\"gmytsojsguzdmmzx\">1</span></span>"
  end
end
