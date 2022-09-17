defmodule Crypto do
  @default_hash :sha256
  @default_hash3 :sha3_256

  @type hash_algorithms :: :md5 | :ripemd160 | :sha | :sha224 | :sha256 | :sha384 | :sha512
  @type hash3_algorithms :: :sha3_224 | :sha3_256 | :sha3_384 | :sha3_512 | :shake128 | :shake256

  @compile {:inline, [hash: 1, hash3: 1, cmac: 2, hmac: 2, hmac: 3, poly1305: 2]}

  @spec hash(iodata(), hash_algorithms) :: binary
  def hash(data, algo \\ @default_hash), do: :crypto.hash(algo, data)

  @spec hash3(binary, hash3_algorithms) :: binary
  def hash3(data, algo \\ @default_hash3), do: :crypto.hash(algo, data)

  @spec hash_file(path :: Path.t(), hash :: hash_algorithms | hash3_algorithms) :: binary
  def hash_file(file_path, algo \\ :sha256) do
    hash_ref = :crypto.hash_init(algo)

    File.stream!(file_path)
    |> Enum.reduce(hash_ref, fn chunk, prev_ref ->
      new_ref = :crypto.hash_update(prev_ref, chunk)
      new_ref
    end)
    |> :crypto.hash_final()
  end

  def cmac(data, key) do
    :crypto.mac(:cmac, :aes_256_cbc, key, data)
  end

  def hmac(data, key, algo \\ :sha3_256) do
    :crypto.mac(:hmac, algo, key, data)
  end

  def poly1305(data, key) do
    :crypto.mac(:poly1305, :crypto.hash(:sha3_256, key), data)
  end
end
