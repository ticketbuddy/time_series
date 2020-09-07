defmodule Test.Support.Repo.Migrations.Measurement do
  use Ecto.Migration

  def change do
    TimeSeries.Migration.Measurement.change()
  end
end
