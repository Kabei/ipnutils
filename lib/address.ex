defmodule Ipnutils.Address do
  def public_address?(<<0, rest::binary>>) when byte_size(rest) == 20, do: true
  def public_address?(_), do: false

  def internal_address?(<<1, rest::binary>>) when byte_size(rest) == 20, do: true
  def internal_address?(_), do: false

  def combined_address?(<<2, rest::binary>>) when byte_size(rest) == 28, do: true
  def combined_address?(_), do: false

  @doc """
  check by address type from pubkey or another method to check it
  """
  # public address
  @spec check_address_pubkey(binary, any) :: boolean()
  def check_address_pubkey(<<0, rest::binary>> = address, pubkey)
      when byte_size(rest) == 20 do
    hash = pubkey |> to_public_address()
    address == hash
  end

  # internal address
  def check_address_pubkey(<<1, rest::binary>> = address, pubkey)
      when byte_size(rest) == 20 do
    hash = pubkey |> to_internal_address()
    address == hash
  end

  # combined address
  def check_address_pubkey(<<2, rest::binary>>, {pubkey, exkey, msg})
      when byte_size(rest) == 28 do
    case Crypto.hash3(pubkey) == msg do
      true ->
        rest == Crypto.hmac(msg, exkey, :sha3_224)

      false ->
        false
    end
  end

  def check_address_pubkey(_, _), do: false

  @public_version_bytes <<0>>
  @internal_version_bytes <<1>>

  @spec to_public_address(binary) :: binary
  def to_public_address(pk) do
    pk
    |> Crypto.hash3()
    |> Crypto.hash(:ripemd160)
    |> append(@public_version_bytes)
  end

  @spec to_internal_address(binary) :: binary
  def to_internal_address(pk) do
    pk
    |> Crypto.hash3()
    |> Crypto.hash3()
    |> :binary.part(0, 20)
    |> append(@internal_version_bytes)
  end

  defp append(checksum, hash), do: hash <> checksum
end
