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
  def init(opts) do
    # IO.inspect("INIT " <> inspect(opts))
    # unless opts[:file]
    #   |> Path.basename("eex")
    #   |> Path.extname()
    #   |> String.downcase() == ".html" do
    #     raise EEx.SyntaxError,
    #     message: """
    #     Trabant.LiveEngine works only with html partials.

    #     Invalid extention of file: #{opts[:file]}.
    #     """
    # end
    file = if opts[:file], do: opts[:file], else: "nofile"
    # Logger.debug(inspect(file))
    Trabant.Amperes.init(file)

    %{
      binary: [],
      dynamic: [],
      vars_count: 0,
      amperes: [],
      file: file
    }
  end

  @impl true
  def handle_body(state) do
    # IO.inspect("BODY1 " <> inspect(state))
    %{binary: binary, dynamic: dynamic, amperes: _amperes, file: file} = state
    binary = {:<<>>, [], Enum.reverse(binary)}
    dynamic = [binary | dynamic]

    found_amperes = Trabant.Amperes.get(file)
    # Logger.debug(inspect(found_amperes))

    amperes_js = amperes_js(found_amperes)
    # Logger.debug(inspect(amperes_js))

    # dynamic = Enum.reverse(dynamic)
    dynamic = dynamic
      # |> Enum.reverse()
      |> add_to_dynamic(amperes_js)
      |> Enum.reverse()

    {:__block__, [], dynamic}
  end

  defp add_to_dynamic([{:<<>>, middle_of_tuple, last_of_tuple} | last], amperes_js) do
    [{:<<>>, middle_of_tuple, last_of_tuple ++ [amperes_js]} | last]
  end

  defp amperes_js(amperes) when is_list(amperes) do
    a =
      amperes
      |> Enum.map(fn x -> x.ampere end)
      |> Enum.join(";")

    "<script>" <> a <> "</script>"
  end

  defp amperes_js(_), do: ""

  @impl true
  def handle_begin(state) do
    # Logger.debug(inspect(state))
    state
  end

  @impl true
  def handle_end(state) do
    # Logger.debug(inspect(state))
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
    found_assigns = find_assigns(ast)

    ast = Macro.prewalk(ast, &EEx.Engine.handle_assign/1)
    line = line_from_expr(ast)

    # EEx.Engine.handle_expr(state, "=", expr)
    %{binary: binary, dynamic: dynamic, vars_count: vars_count, amperes: amperes, file: file} =
      state

    # binary_first = List.first(binary)
    var = Macro.var(:"arg#{vars_count}", __MODULE__)

    ampere_id = Trabant.Tokenizer.hash(state)
    # ampere_id = Enum.join(found_assigns, ",")
    ampere_attribute = "trabant_ampere=\"#{ampere_id}\""

    binary = Trabant.Tokenizer.deep_reverse(binary)

    binary =
      if found_assigns != [] do
        case Trabant.Tokenizer.inject_attribute_to_last_opened(binary, ampere_attribute) do
          # injected!
          {:ok, buf, _amp} ->
            buf

          # it was already there
          {:already_there, _, _amp} ->
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

    binary = Trabant.Tokenizer.deep_reverse(binary)

    ast =
      quote do
        unquote(var) = String.Chars.to_string(unquote(ast))
      end

    segment =
      quote do
        unquote(var) :: binary
      end

    # Logger.debug(inspect([%{ampere: ampere_id, ast: ast, assigns: found_assigns} | amperes]))

    amperes1 = [%{ast: ast, assigns: found_assigns} | amperes]

    amperes2 =
      List.flatten([Trabant.Amperes.get(file)], [%{ampere: ampere_id, assigns: found_assigns}])
      |> Enum.filter(&(!is_nil(&1)))

    # amperes2 = CubDB.get_and_update(:db, file, fn x -> x end)
    Trabant.Amperes.put(%{ampere: ampere_id}, amperes1)
    Trabant.Amperes.put(file, amperes2)

    %{
      state
      | dynamic: [ast | dynamic],
        binary: [segment | binary],
        vars_count: vars_count + 1,
        amperes: amperes
    }
  end

  def handle_expr(state, marker, expr) do
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
