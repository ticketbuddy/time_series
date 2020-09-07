defmodule TimeSeries.Schema.Measurement do
  use Ecto.Schema
  @primary_key {:measurement_id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime]

  schema "measurement" do
    field(:name, :string, null: false)
    field(:time, :utc_datetime)
    field(:value, :integer)
    field(:dimensions, :map, null: false)
  end

  def changeset(params) do
    import Ecto.Changeset

    %__MODULE__{}
    |> cast(params, [:name, :time, :dimensions, :value])
    |> validate_required([:name, :time, :dimensions, :value])
    |> unique_constraint([:name, :time],
      name: :time_locking
    )
  end
end
