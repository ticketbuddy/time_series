defmodule TimeSeries.Clock do
  def truncate(datetime, :minute) do
    dt = DateTime.truncate(datetime, :second)

    %DateTime{dt | second: 0}
  end

  def truncate(datetime, :hour) do
    dt = truncate(datetime, :minute)

    %DateTime{dt | minute: 0}
  end
end
