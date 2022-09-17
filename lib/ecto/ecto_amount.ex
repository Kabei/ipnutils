defmodule Ecto.Amount do
  use Ecto.Type

  @impl true
  def type, do: :integer

  @impl true
  def cast(number) when is_integer(number) do
    {:ok, Decimal.new(number)}
  end

  def cast(_), do: :error

  @impl true
  def load(decimal) do
    {:ok, Decimal.to_integer(decimal)}
  end

  @impl true
  def dump(integer), do: {:ok, Decimal.new(integer)}

  @impl true
  def equal?(term1, term2), do: term1 == term2

  @impl true
  def embed_as(_format), do: :self
end
