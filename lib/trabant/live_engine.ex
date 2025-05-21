defmodule Trabant.LiveEngine do
  @moduledoc """
  The Trabant engine in a HTML.

  It includes assigns (like `@foo`).

  ## Examples

      iex> EEx.eval_string("<%= @foo %>", assigns: [foo: 1], engine: Trabant.LiveEngine)
      "1"

  In the example above, we can access the value `foo` under
  the binding `assigns` using `@foo`. This is useful because
  a template, after being compiled, can receive different
  assigns and would not require recompilation for each
  variable set.

  Assigns can also be used when compiled to a function:

      # sample.eex
      <%= @a + @b %>

      # sample.ex
      defmodule Sample do
        require EEx
        EEx.function_from_file(:def, :sample, "sample.eex", [:assigns])
      end

      # iex
      Sample.sample(a: 1, b: 2)
      #=> "3"

  """

  @behaviour EEx.Engine
  require Logger

  @impl true
  def init(_opts) do
    # IO.inspect("INIT " <> inspect(opts))
    %{
      binary: [],
      dynamic: [],
      vars_count: 0
    }
  end

  @impl true
  def handle_body(state) do
    # IO.inspect("BODY1 " <> inspect(state))
    %{binary: binary, dynamic: dynamic} = state
    binary = {:<<>>, [], Enum.reverse(binary)}
    dynamic = [binary | dynamic]
    # IO.inspect("BODY2 " <> inspect({:__block__, [], Enum.reverse(dynamic)}), pretty: true)
    {:__block__, [], Enum.reverse(dynamic)}
  end

  @impl true
  def handle_begin(state) do
    # IO.inspect("BEGIN " <> state)
    state
  end

  @impl true
  def handle_end(state) do
    # IO.inspect("END " <> state)
    state
  end

  @impl true
  # defdelegate handle_text(state, meta, text), to: EEx.Engine
  def handle_text(state, _meta, text) do
    # check_state!(state)
    %{binary: binary} = state
    # IO.inspect("TEXT " <> inspect(state))
    %{state | binary: [text | binary]}
  end

  @impl true
  def handle_expr(state, "=", ast) do
    # IO.inspect("EXPR ESSION " <> inspect(ast))
    ast = Macro.prewalk(ast, &EEx.Engine.handle_assign/1)

    # EEx.Engine.handle_expr(state, "=", expr)
    %{binary: binary, dynamic: dynamic, vars_count: vars_count} = state
    var = Macro.var(:"arg#{vars_count}", __MODULE__)

    ast =
      quote do
        unquote(var) = String.Chars.to_string(unquote(ast))
      end

    segment =
      quote do
        unquote(var) :: binary
      end

    # IO.inspect("AFTER: " <> inspect(%{state | dynamic: [ast | dynamic], binary: [segment | binary], vars_count: vars_count + 1}))
    %{state | dynamic: [ast | dynamic], binary: [segment | binary], vars_count: vars_count + 1}
  end

  def handle_expr(state, marker, expr) do
    # IO.inspect("EXPR " <> inspect(expr))
    expr = Macro.prewalk(expr, &EEx.Engine.handle_assign/1)
    EEx.Engine.handle_expr(state, marker, expr)
  end
end
