defmodule Test.Support.Helper do
  @valid_measures [:hours, :minutes, :seconds]

  def time_travel(datetime, {value, measurement})
      when value > 0 and measurement in @valid_measures do
    opts = Keyword.new([{measurement, value}])
    Timex.shift(datetime, opts)
  end

  defmacro __using__(repo: repos) do
    quote do
      setup tags do
        unquote(repos)
        |> List.wrap()
        |> Enum.each(fn repo ->
          :ok = Ecto.Adapters.SQL.Sandbox.checkout(repo)

          unless tags[:async] do
            Ecto.Adapters.SQL.Sandbox.mode(
              repo,
              {:shared, self()}
            )
          end
        end)

        :ok
      end
    end
  end
end
