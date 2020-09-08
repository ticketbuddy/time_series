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
end
