defmodule Test.Support.Repo.Migrations.Measurement do
  use Ecto.Migration

  def change do
    create table("measurement", primary_key: false) do
      add(:measurement_id, :uuid, primary_key: true, null: false)
      add(:name, :string, null: false)
      add(:time, :utc_datetime)
      add(:dimensions, :map, null: false)
    end

    create(
      unique_index(
        :measurement,
        [:name, :time],
        name: :time_locking
      )
    )
  end
end
