defmodule ByteUtils do
  @doc """
  fill zeros pad leading
  x: binary data
  usize: bit size
  """
  def zeros_pad_leading(x, usize) when bit_size(x) < usize do
    rest_size = usize - bit_size(x)

    [<<0::size(rest_size)>>, x]
    |> IO.iodata_to_binary()
  end

  def zeros_pad_leading(x, _usize), do: x
end
