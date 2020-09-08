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

    test "increments same datetime (default truncated hour), same metric name" do
      dimensions = %{
        environment: "live"
      }

      occured_at = DateTime.utc_now()

      assert :ok == MyTimeSeriesApp.inc("a-metric", dimensions, time: occured_at)
      assert :ok == MyTimeSeriesApp.inc("a-metric", dimensions, time: occured_at)

      truncated_occured_at = TimeSeries.Clock.truncate(occured_at, :hour)

      assert %TimeSeries.Schema.Measurement{
               dimensions: %{"environment" => "live"},
               name: "a-metric",
               value: 2
             } =
               Test.Support.Repo.get_by(TimeSeries.Schema.Measurement, time: truncated_occured_at)
    end
  end

  describe "queries records" do
    test "fetches records between two times" do
      time_one = ~U[2020-09-07 17:24:00Z]
      time_two = ~U[2020-09-07 23:24:00Z]

      dimensions = %{env: "test"}

      assert [
               [~N[2020-09-07 20:00:00.000000], 3],
               [~N[2020-09-07 23:00:00.000000], 3]
             ] == MyTimeSeriesApp.read("seeded-metric-name", dimensions, {time_one, time_two})
    end

    test "when granularity is set to weekly" do
      time_one = ~U[2020-09-07 17:24:00Z]
      time_two = ~U[2020-09-09 23:24:00Z]

      dimensions = %{env: "test"}
      granularity = "week"

      assert [
               [~N[2020-09-07 00:00:00.000000], 54]
             ] ==
               MyTimeSeriesApp.read(
                 "seeded-metric-name",
                 dimensions,
                 {time_one, time_two},
                 granularity
               )
    end

    test "when granularity is daily" do
      time_one = ~U[2020-09-07 17:24:00Z]
      time_two = ~U[2020-09-09 23:24:00Z]

      dimensions = %{env: "test"}
      granularity = "day"

      assert [
               [~N[2020-09-07 00:00:00.000000], 6],
               [~N[2020-09-08 00:00:00.000000], 24],
               [~N[2020-09-09 00:00:00.000000], 24]
             ] ==
               MyTimeSeriesApp.read(
                 "seeded-metric-name",
                 dimensions,
                 {time_one, time_two},
                 granularity
               )
    end

    test "when granularity is monthly" do
      time_one = ~U[2020-09-07 17:24:00Z]
      time_two = ~U[2020-09-09 23:24:00Z]

      dimensions = %{env: "test"}
      granularity = "month"

      assert [{~N[2020-09-01 00:00:00.000000], 54}],
             MyTimeSeriesApp.read(
               "seeded-metric-name",
               dimensions,
               {time_one, time_two},
               granularity
             )
    end

    test "when no dimensions are given" do
      time_one = ~U[2020-09-07 17:24:00Z]
      time_two = ~U[2020-09-07 23:24:00Z]

      dimensions = %{}

      assert [
               [~N[2020-09-07 20:00:00.000000], 3],
               [~N[2020-09-07 23:00:00.000000], 3]
             ] == MyTimeSeriesApp.read("seeded-metric-name", dimensions, {time_one, time_two})
    end

    test "when dimensions do not match, runs query without dimensions checks" do
      time_one = ~U[2020-09-07 17:24:00Z]
      time_two = ~U[2020-09-07 23:24:00Z]

      dimensions = %{env: "foo"}

      assert [] == MyTimeSeriesApp.read("seeded-metric-name", dimensions, {time_one, time_two})
    end

    test "when times don't return any records" do
      time_one = ~U[2020-09-07 17:24:00Z]
      time_two = ~U[2020-09-07 19:24:00Z]

      dimensions = %{env: "test"}

      assert [] == MyTimeSeriesApp.read("seeded-metric-name", dimensions, {time_one, time_two})
    end
  end
end
