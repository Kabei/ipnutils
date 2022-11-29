defmodule Inet do
  def get_public_ip do
    {:ok, {_, _, inet_addr}} = :httpc.request('http://api64.ipify.org')
    inet_addr
  end

  @spec remote_ip_port(Plug.Conn.t()) :: {Tuple.t(), integer}
  def remote_ip_port(conn) do
    {_mod, socket} = conn.adapter
    socket.peer
  end

  def subnet({a, b, c, _d}) do
    {a, b, c, 0}
  end

  def to_str(address) when address |> is_binary do
    address
  end

  def to_str(address) when address |> is_list do
    address |> IO.iodata_to_binary()
  end

  def to_str(ipaddress) do
    :inet.ntoa(ipaddress)
    |> to_string
  end

  def to_number({a, b, c, d}) do
    <<a, b, c, d>>
    |> :binary.decode_unsigned()
  end

  def to_number({a, b, c, d, e, f, g, h}) do
    <<a::16, b::16, c::16, d::16, e::16, f::16, g::16, h::16>>
    |> :binary.decode_unsigned()
  end

  def to_ip(x) when is_binary(x) do
    x
    |> to_charlist()
    |> :inet.parse_address()
    |> elem(1)
  end

  def to_ip(x) do
    :inet.parse_address(x)
    |> elem(1)
  end

  def resolve_ip(host) do
    host |> to_charlist() |> :inet_udp.getaddr() |> elem(1)
  end
end
