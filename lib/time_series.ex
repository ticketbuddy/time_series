defmodule TimeSeries do
  @moduledoc """
  Documentation for TimeSeries.
  """
  alias TimeSeries.Schema

  def inc(repo, name, dimensions, opts) do
    time = Keyword.get(opts, :time, DateTime.utc_now())
    value = Keyword.get(opts, :value, 1)

    Schema.Measurement.changeset(%{
      name: name,
      time: time,
      value: value,
      dimensions: dimensions
    })
    |> repo.insert(conflict_target: [:name, :time], on_conflict: [inc: [value: value]])
    |> format_result()
  end

  def read(repo, metric, dimensions, time_span) do
    import Ecto.Query
    import Ecto.Query.API
    import TimeSeries.Query

    Schema.Measurement
    |> where(
      [_q],
      ^json_multi_expressions(:dimensions, dimensions)
    )
    |> where(name: ^metric)
    |> repo.all()
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
