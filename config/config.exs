import Mix.Config

config :time_series, ecto_repos: [Test.Support.Repo]

config :time_series, Test.Support.Repo,
  database: "time_series",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
