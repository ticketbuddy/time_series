defmodule TimeSeries.Schema.Measurement do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:measurement_id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime]

  schema "measurement" do
    field(:name, :string, null: false)
    field(:time, :utc_datetime)
    field(:value, :integer)
    field(:dimensions, :map, null: false)
    field(:hash, :string, null: false)
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:name, :time, :dimensions, :value])
    |> validate_required([:name, :time, :dimensions, :value])
    |> put_hash()
    |> unique_constraint([:time, :hash],
      name: :time_locking
    )
  end

  def put_hash(changeset) do
    hash =
      Crimpex.signature(%{
        name: changeset.changes.name,
        dimensions: changeset.changes.dimensions
      })

    changeset
    |> put_change(:hash, hash)
  end
end
