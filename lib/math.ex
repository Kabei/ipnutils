defmodule Math do
  @spec most_reliable([number()], integer()) :: number()
  def most_reliable(x, i) when i <= 0, do: Enum.sum(x) |> div(length(x))

  def most_reliable(x, i) do
    avg = Enum.sum(x) / length(x)

    x1 = Enum.filter(x, &(&1 > avg))
    x2 = Enum.filter(x, &(&1 < avg))
    x3 = Enum.filter(x, &(&1 == avg))

    l1 = length(x1)
    l2 = length(x2)
    l3 = length(x3)
    {c, x} = Enum.max([{l1, x1}, {l2, x2}, {l3, x3}])
    equals = Enum.filter([l1, l2, l3], &(&1 == c)) |> length()

    cond do
      equals > 1 -> avg
      true -> most_reliable(x, i - 1)
    end
  end
end
