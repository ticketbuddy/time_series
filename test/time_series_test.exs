defmodule TimeSeriesTest do
  use ExUnit.Case
  use Test.Support.Helper, repo: Test.Support.Repo

  defmodule MyTimeSeriesApp do
    use TimeSeries, repo: Test.Support.Repo
  end

  describe "incrementing a metric" do
    test "increments a metric" do
      dimensions = %{
        environment: "live"
      }

      assert :ok == MyTimeSeriesApp.inc("a-metric", dimensions)
    end

    test "increments a metric with a custom value" do
      dimensions = %{
        environment: "live"
      }

      assert :ok == MyTimeSeriesApp.inc("a-metric", dimensions, value: 4_385)

      assert %TimeSeries.Schema.Measurement{
               dimensions: %{"environment" => "live"},
               measurement_id: _measurement_id,
               name: "a-metric",
               time: _time,
               value: 4385
             } = Test.Support.Repo.get_by(TimeSeries.Schema.Measurement, value: 4_385)
    end

    test "increments same datetime, differing metric name" do
      dimensions = %{
        environment: "live"
      }

      occured_at = DateTime.utc_now()

      assert :ok == MyTimeSeriesApp.inc("a-metric", dimensions, time: occured_at)
      assert :ok == MyTimeSeriesApp.inc("another-metric", dimensions, time: occured_at)
    end

    test "increments same datetime, same metric name" do
      dimensions = %{
        environment: "live"
      }

      occured_at = DateTime.utc_now()

      assert :ok == MyTimeSeriesApp.inc("a-metric", dimensions, time: occured_at)
      assert :ok == MyTimeSeriesApp.inc("a-metric", dimensions, time: occured_at)

      assert %TimeSeries.Schema.Measurement{
               dimensions: %{"environment" => "live"},
               name: "a-metric",
               value: 2
             } = Test.Support.Repo.get_by(TimeSeries.Schema.Measurement, time: occured_at)
    end
  end
end
