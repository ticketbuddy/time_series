defmodule TimeSeries.Clock do
  def truncate(datetime, :minute) do
    dt = DateTime.truncate(datetime, :second)

    %DateTime{dt | second: 0}
  end

  def truncate(datetime, :hour) do
    dt = truncate(datetime, :minute)

    %DateTime{dt | minute: 0}
  end

  def build_empty_hours(from, till, list \\ []) do
    start = truncate(from, :hour)
    add_next_hour(%{start => 0}, start, till)
  end

  def add_next_hour(times, previous, till) do
    next = Timex.shift(previous, [{:hours, 1}])

    case DateTime.compare(next, till) do
      :gt -> times
      _ -> add_next_hour(Map.put_new(times, next, 0), next, till)
    end
  end
end
