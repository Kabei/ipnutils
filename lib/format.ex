defmodule Format do
  @compile {:inline, timestamp: 1}
  def timestamp(t) do
    DateTime.from_unix!(t, :millisecond) |> DateTime.to_iso8601()
  end
end
