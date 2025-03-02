defmodule TimeSeries do
  @moduledoc """
  Documentation for TimeSeries.
  """

  alias TimeSeries.Clock

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
    |> repo.insert(conflict_target: [:hash, :time], on_conflict: [inc: [value: value]])
    |> format_result()
  end

  def read(repo, metric, dimensions, {from, till}) do
    timezone = "UTC"

    empty_hours = Clock.build_empty_hours(from, till)

    from(
      m in Schema.Measurement,
      where: m.time >= ^from,
      where: m.time <= ^till,
      select: {m.time, sum(m.value)},
      order_by: m.time,
      group_by: m.time
    )
    |> where_dimensions(dimensions)
    |> where(name: ^metric)
    |> repo.all()
    |> Enum.into(empty_hours)
    |> order()
  end

  defp order(data) when is_map(data) do
    data
    |> Enum.reduce([], fn {date, value}, acc ->
      [[date, value] | acc]
    end)
    |> Enum.sort(fn [dt_one, _], [dt_two, _] ->
      DateTime.compare(dt_one, dt_two) != :gt
    end)
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
