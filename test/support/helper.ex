defmodule Test.Support.Helper do
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
