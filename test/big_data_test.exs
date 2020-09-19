defmodule BigDataTest do
  use ExUnit.Case
  use Test.Support.Helper, repo: Test.Support.Repo

  @seconds_per_day 86400

  defmodule MyTimeSeriesApp do
    use TimeSeries, repo: Test.Support.Repo
  end

  test "when asking for a log of data points" do
    till = ~U[2020-09-17 17:00:00Z]
    from = DateTime.add(till, -(75 * @seconds_per_day), :second)
    dimensions = %{}

    dates = MyTimeSeriesApp.read("seeded-metric-name", dimensions, {from, till})

    dates
    |> Enum.with_index()
    |> Enum.each(fn {[date, _], index} ->
      unless index == 0 do
        [previous, _] = Enum.at(dates, index - 1)

        assert :gt == DateTime.compare(date, previous)
      end
    end)
  end
end
