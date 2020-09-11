defmodule TimeSeries do
  @moduledoc """
  Documentation for TimeSeries.
  """

  import Ecto.Query
  import TimeSeries.Query

  alias TimeSeries.Schema

  def inc(repo, name, dimensions, opts) do
    time = Keyword.get(opts, :time, DateTime.utc_now())
    value = Keyword.get(opts, :value, 1)
    accuracy = Keyword.get(opts, :accuracy, :hour)

    Schema.Measurement.changeset(%{
      name: name,
      time: TimeSeries.Clock.truncate(time, accuracy),
      value: value,
      dimensions: dimensions
    })
    |> repo.insert(conflict_target: [:name, :time], on_conflict: [inc: [value: value]])
    |> format_result()
  end

  def read(repo, metric, dimensions, {from, till}) do
    timezone = "UTC"

    from(
      m in Schema.Measurement,
      where: m.time >= ^from,
      where: m.time <= ^till,
      select: [m.time, sum(m.value)],
      order_by: m.time,
      group_by: m.time
    )
    |> where_dimensions(dimensions)
    |> where(name: ^metric)
    |> repo.all()
  end

  defp where_dimensions(query, dimensions) do
    if dimensions == %{} do
      query
    else
      query
      |> where(
        [_q],
        ^json_multi_expressions(:dimensions, dimensions)
      )
    end
  end

  defp format_result({:ok, _result}), do: :ok
  defp format_result({:error, _result}), do: :error

  defmacro __using__(repo: repo) do
    quote do
      @repo unquote(repo)

      def inc(name, dimensions, opts \\ []) do
        TimeSeries.inc(@repo, name, dimensions, opts)
      end

      def read(metric, dimensions, time_span) do
        TimeSeries.read(@repo, metric, dimensions, time_span)
      end
    end
  end
end
