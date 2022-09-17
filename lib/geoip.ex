defmodule GeoIP do
  # IPv4
  @data Code.eval_file("priv/geoip/ipv4.exs")
        |> elem(0)

  # IPv6
  @data6 Code.eval_file("priv/geoip/ipv6.exs")
         |> elem(0)

  @spec filter(Tuple.t()) :: String.t()
  def filter(ip_addr) do
    netmask = tuple_size(ip_addr)
    x = Inet.to_number(ip_addr)

    data =
      case netmask do
        4 ->
          @data

        _ ->
          @data6
      end

    Enum.reduce_while(data, nil, fn {range, country}, acc ->
      case x in range do
        true ->
          {:halt, country}

        false ->
          {:cont, acc}
      end
    end)
  end
end
