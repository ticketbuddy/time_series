defmodule Test.Support.Repo do
  use Ecto.Repo, otp_app: :time_series, adapter: Ecto.Adapters.Postgres
end
