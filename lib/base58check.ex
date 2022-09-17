defmodule Base58Check do
  @public_version_bytes <<0>>
  @internal_version_bytes <<1>>
  # @combined_version_bytes <<2>>

  @spec public_address(binary) :: binary
  def public_address(pk) do
    pk
    |> Crypto.hash3()
    |> Crypto.hash(:ripemd160)
    |> append(@public_version_bytes)
    |> base58check_hash()
  end

  def internal_address(pk) do
    pk
    |> Crypto.hash3()
    |> Crypto.hash(:sha)
    |> append(@internal_version_bytes)
    |> base58check_hash()
  end

  @spec encode(binary()) :: String.t()
  def encode(<<version::bytes-size(1), hash::bits>>) do
    hash
    |> Base58.encode()
    |> append(Base58.encode(version))
  end

  @spec decode(String.t()) :: binary
  def decode(address) do
    <<version::bytes-size(1), rest::binary>> = address

    fix_size = fix_bit_size_version(version)

    rest
    |> Base58.decode()
    |> ByteUtils.zeros_pad_leading(fix_size)
    |> append(Base58.decode(version))
  end

  @spec valid?(binary) :: :ok | {:error, atom()}
  def valid?(<<first::bytes-size(21), checksum::bytes-size(4)>>) do
    checksum2 =
      first
      |> Crypto.hash3()
      |> Crypto.hash3()
      |> checksum()

    if checksum2 == checksum, do: :ok, else: {:error, :invalid_address}
  end

  def valid?(_), do: {:error, :invalid_address}

  def extract_hash_from58(base58address) do
    base58address
    |> decode()
    |> extract_hash()
  end

  @spec extract_hash(binary()) :: binary() | {:error, atom()}
  def extract_hash(<<first::bytes-size(21), _checksum::bytes-size(4)>>) do
    first
  end

  def extract_hash(_), do: {:error, :invalid_address}

  defp base58check_hash(versioned_hash) do
    versioned_hash
    |> Crypto.hash3()
    |> Crypto.hash3()
    |> checksum()
    |> append(versioned_hash)
  end

  defp append(checksum, hash), do: hash <> checksum

  defp checksum(<<checksum::bytes-size(4), _::bits>>), do: checksum

  # Return bit size according to version of address
  defp fix_bit_size_version(@public_version_bytes), do: 160
  defp fix_bit_size_version(@internal_version_bytes), do: 160
  defp fix_bit_size_version(_), do: 160
end
