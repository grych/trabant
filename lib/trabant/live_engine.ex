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
    # IO.inspect("BODY2 " <> inspect(state))
    # IO.inspect("BODY3 " <> inspect({:__block__, [], Enum.reverse(dynamic)}), pretty: true)
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
    # IO.inspect("EXPRESSION " <> inspect(ast))

    found_assigns = find_assigns(ast)
    # Logger.info("ASSIGNS: " <> inspect(found_assigns))

    ast = Macro.prewalk(ast, &EEx.Engine.handle_assign/1)
    line = line_from_expr(ast)

    # EEx.Engine.handle_expr(state, "=", expr)
    %{binary: binary, dynamic: dynamic, vars_count: vars_count} = state
    # binary_first = List.first(binary)
    var = Macro.var(:"arg#{vars_count}", __MODULE__)

    ampere_id = Trabant.Tokenizer.hash(state)
    # Logger.debug(inspect(:rand.uniform(100)))
    ampere_attribute = "trabant_ampere=\"#{ampere_id}\""

    # Logger.info("BINARY: " <> inspect(binary))
    # Logger.info("ampere_attribute: " <> inspect(ampere_attribute))
    # binary = Trabant.Tokenizer.deep_reverse(binary)
    # Logger.info("state: " <> inspect(state))
    binary = Trabant.Tokenizer.deep_reverse(binary)
    binary = if found_assigns != [] do
      case Trabant.Tokenizer.inject_attribute_to_last_opened(binary, ampere_attribute) do
        # injected!
        {:ok, buf, _amp} ->
          buf

        # it was already there
        {:already_there, _, _amp} ->
          # Logger.error("ALREADY THERE " <> inspect(Trabant.Tokenizer.extract_ampere_hash(amp)))
          binary

        {:not_found, _, _} ->
          raise EEx.SyntaxError,
            message: """
            can't find the parent tag for an expression in line #{line}.
            """
      end
    else
      binary
    end
    # binary = Trabant.Tokenizer.deep_reverse(binary)
    # Logger.error("EXPRESSION " <> inspect(binary))
    binary = Trabant.Tokenizer.deep_reverse(binary)

    ast =
      quote do
        unquote(var) = String.Chars.to_string(unquote(ast))
      end

    segment =
      quote do
        unquote(var) :: binary
      end

    # IO.inspect("AFTER EXPR: " <> inspect(%{state | dynamic: [ast | dynamic], binary: [segment | binary], vars_count: vars_count + 1}))
    %{state | dynamic: [ast | dynamic], binary: [segment | binary], vars_count: vars_count + 1}
  end

  def handle_expr(state, marker, expr) do
    # IO.inspect("EXPR " <> inspect(expr))
    expr = Macro.prewalk(expr, &EEx.Engine.handle_assign/1)
    EEx.Engine.handle_expr(state, marker, expr)
  end

  defp line_from_expr({_, meta, _}) when is_list(meta), do: Keyword.get(meta, :line)
  defp line_from_expr(_), do: nil

  defp find_assigns(ast) do
    {_, result} =
      Macro.prewalk(ast, [], fn node, acc ->
        case node do
          # {{:., _, [{:__aliases__, _, [:Phoenix, :HTML, :Engine]}, :fetch_assign!]}, _, [_, name]}
          {:@, _, [{name, _, _}]}
          when is_atom(name) ->
            {node, [name | acc]}

          _ ->
            {node, acc}
        end
      end)

    result |> Enum.uniq() |> Enum.sort()
  end
end
