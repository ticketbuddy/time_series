defmodule TimeSeriesTest do
  use ExUnit.Case
  use Test.Support.Helper, repo: Test.Support.Repo

  defmodule MyTimeSeriesApp do
    use TimeSeries, repo: Test.Support.Repo
  end

  test "increments a metric" do
    dimensions = %{
      environment: "live"
    }

    assert :ok == MyTimeSeriesApp.inc("a-metric", dimensions)
  end
end
