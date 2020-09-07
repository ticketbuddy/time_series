alias Test.Support.Repo
alias TimeSeries.Schema.Measurement

{:ok, _} = Ecto.Adapters.Postgres.ensure_all_started(Repo, :temporary)
{:ok, _pid} = Repo.start_link()

for c <- 1..80 do
  if rem(c, 3) == 0 do
    dt = Test.Support.Helper.time_travel(~U[2020-09-07 17:00:00Z], {c, :hours})
    Repo.insert!(%Measurement{
      time: dt,
      name: "seeded-metric-name",
      value: 3,
      dimensions: %{env: "test"}
    })
  end
end

for c <- 1..50 do
  if rem(c, 2) == 0 do
    dt = Test.Support.Helper.time_travel(~U[2020-09-07 17:00:00Z], {c, :hours})
    Repo.insert!(%Measurement{
      time: dt,
      name: "another-metric-name",
      value: 5,
      dimensions: %{env: "live"}
    })
  end
end

IO.puts "Seeded."
