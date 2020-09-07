defmodule TimeSeries.Query do
  import Ecto.Query
  import Ecto.Query.API

  @doc """
  CREDIT TO: https://www.hatethatcode.com/a-macro-to-query-over-multiple-fields-of-a-jsonb-column.html

  A macro that generates multiple fragments using dynamic expressions.

  Options

    * `conjunction`: define whether to use `and` or `or` to join dynamic
    expressions for each parameter. By default uses `and`.
    * `gen_dynamic` - An optional function to generate a dynamic fragment
    (using `Ecto.Query.dynamic`).
  """
  defmacro json_multi_expressions(col, params, opts \\ []) do
    # conjuctive operator to be used between fragments
    conjunction = Keyword.get(opts, :conjunction, :and)
    # a function that generates a dynamic expression
    quote do
      TimeSeries.Query.build_expressions(
        unquote(params),
        unquote(col),
        unquote(conjunction)
      )
    end
  end

  def build_expressions(params, col, conjunction)

  def build_expressions(params, col, conjunction) do
    Enum.reduce(params, nil, fn {key, val}, acc ->
      frag =
        TimeSeries.Query.build_fragment(
          col,
          to_string(key),
          val
        )

      # TODO I'd write this using a case, but it generates a compilation warning
      # https://github.com/elixir-lang/elixir/issues/6738
      TimeSeries.Query.do_combine(frag, acc, conjunction)
    end)
  end

  def build_fragment(col, key, val) do
    # build default dynamic fragment
    dynamic(
      [q],
      fragment(
        "?::jsonb @> ?::jsonb",
        field(q, ^col),
        ^%{key => val}
      )
    )
  end

  @doc false
  def do_combine(frag, acc, conjunction)
  def do_combine(frag, nil, _), do: frag
  def do_combine(frag, acc, :or), do: dynamic([q], ^acc or ^frag)
  def do_combine(frag, acc, _), do: dynamic([q], ^acc and ^frag)
end
