defmodule Ipnutils.MigrationHelper do
  @repo Application.get_env(:ipnutils, :repo)

  def run([]), do: :ok

  def run([qry | rest]) do
    Ecto.Adapters.SQL.query!(@repo, qry, [])
    run(rest)
  end

  def run(qry) when is_binary(qry) do
    Ecto.Adapters.SQL.query!(@repo, qry, [])
    :ok
  end

  defmacro __using__(_opts) do
    quote do
      import Ipnutils.MigrationHelper

      def build(opts) do
        qry = up(opts)

        run(qry)
      end

      def destroy(opts) do
        qry = down(opts)

        run(qry)
      end
    end
  end
end
