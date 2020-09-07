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
    |> repo.insert()
    |> format_result()
  end

  defp format_result({:ok, _result}), do: :ok
  defp format_result({:error, _result}), do: :error

  defmacro __using__(repo: repo) do
    quote do
      @repo unquote(repo)

      def inc(name, dimensions, opts \\ []) do
        TimeSeries.inc(@repo, name, dimensions, opts)
      end
    end
  end
end
