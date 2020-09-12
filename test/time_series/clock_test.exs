defmodule TimeSeries.ClockTest do
  use ExUnit.Case
  alias TimeSeries.Clock

  test "truncates by minute" do
    dt = ~U[2020-09-08 18:16:55.857239Z]
    assert ~U[2020-09-08 18:16:00Z] == Clock.truncate(dt, :minute)
  end

  test "truncates by hour" do
    dt = ~U[2020-09-08 18:16:55.857239Z]
    assert ~U[2020-09-08 18:00:00Z] == Clock.truncate(dt, :hour)
  end

  describe "builds list of times, between two dates" do
    test "hourly interval" do
      from = ~U[2020-09-08 02:08:00Z]
      till = ~U[2020-09-08 23:09:00Z]

      assert %{
               ~U[2020-09-08 02:00:00Z] => 0,
               ~U[2020-09-08 03:00:00Z] => 0,
               ~U[2020-09-08 04:00:00Z] => 0,
               ~U[2020-09-08 05:00:00Z] => 0,
               ~U[2020-09-08 06:00:00Z] => 0,
               ~U[2020-09-08 07:00:00Z] => 0,
               ~U[2020-09-08 08:00:00Z] => 0,
               ~U[2020-09-08 09:00:00Z] => 0,
               ~U[2020-09-08 10:00:00Z] => 0,
               ~U[2020-09-08 11:00:00Z] => 0,
               ~U[2020-09-08 12:00:00Z] => 0,
               ~U[2020-09-08 13:00:00Z] => 0,
               ~U[2020-09-08 14:00:00Z] => 0,
               ~U[2020-09-08 15:00:00Z] => 0,
               ~U[2020-09-08 16:00:00Z] => 0,
               ~U[2020-09-08 17:00:00Z] => 0,
               ~U[2020-09-08 18:00:00Z] => 0,
               ~U[2020-09-08 19:00:00Z] => 0,
               ~U[2020-09-08 20:00:00Z] => 0,
               ~U[2020-09-08 21:00:00Z] => 0,
               ~U[2020-09-08 22:00:00Z] => 0,
               ~U[2020-09-08 23:00:00Z] => 0
             } == Clock.build_empty_hours(from, till)
    end
  end
end
