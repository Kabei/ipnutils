defmodule Ipnutils.FastGlobal do
  @spec do_delete(atom) :: boolean
  def do_delete(module) do
    :code.purge(module)
    :code.delete(module)
  end

  @spec compile(atom, any) :: binary
  def compile(module, value) do
    {:ok, ^module, binary} =
      module
      |> value_to_abstract(value)
      |> Enum.map(&:erl_syntax.revert/1)
      |> :compile.forms([:verbose, :report_errors])

    binary
  end

  @spec value_to_abstract(atom, any) :: [:erl_syntax.syntaxTree()]
  def value_to_abstract(module, value) do
    import :erl_syntax

    [
      # -module(module).
      attribute(
        atom(:module),
        [atom(module)]
      ),
      # -export([value/0]).
      attribute(
        atom(:export),
        [list([arity_qualifier(atom(:value), integer(0))])]
      ),
      # value() -> value.
      function(
        atom(:value),
        [clause([], :none, [abstract(value)])]
      )
    ]
  end

  defmacro __using__(opts \\ []) do
    quote do
      import Ipnutils.FastGlobal

      # @compile {:inline, get: 1, get: 2, put: 2, key_to_module: 1, do_get: 2, do_put: 2}
      @module Keyword.get(unquote(opts), :name, __MODULE__)
      @erl_module '#{@module}.erl'
      @compile {:inline, get: 1, get: 2, put: 2, key_to_module: 1, do_get: 2, do_put: 2}

      # @type t :: {__MODULE__, atom}

      @spec key_to_module(atom) :: atom
      def key_to_module(key) do
        # Don't use __MODULE__ because it is slower.
        :"Elixir.#{@module}.#{key}"
      end

      @spec do_put(atom, any) :: :ok
      def do_put(module, value) do
        binary = compile(module, value)
        :code.purge(module)
        {:module, ^module} = :code.load_binary(module, @erl_module, binary)
        :ok
      end

      @doc """
      Create a module for the Global instance.
      """

      # @spec new(atom) :: {any, atom}
      # def new(key) do
      #   {@module, key_to_module(key)}
      # end

      @doc """
      Get the value for `key` or return nil.
      """
      @spec get(atom) :: any | nil
      def get(key), do: get(key, nil)

      @doc """
      Get the value for `key` or return `default`.
      """
      @spec get(atom, any) :: any
      # def get({__MODULE__, module}, default), do: do_get(module, default)
      def get(key, default), do: key |> key_to_module |> do_get(default)

      @doc """
      Store `value` at `key`, replaces an existing value if present.
      """
      @spec put(atom, any) :: :ok
      # def put({__MODULE__, module}, value), do: do_put(module, value)
      def put(key, value), do: key |> key_to_module |> do_put(value)

      @doc """
      Delete value stored at `key`, no-op if non-existent.
      """
      @spec delete(atom) :: :ok
      # def delete({__MODULE__, module}), do: do_delete(module)
      def delete(key), do: key |> key_to_module |> do_delete

      @spec do_get(atom, any) :: any
      defp do_get(module, default) do
        try do
          module.value
        catch
          :error, :undef ->
            default
        end
      end
    end
  end
end
