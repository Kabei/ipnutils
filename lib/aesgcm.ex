defmodule AESGCM do
  @moduledoc """
  This module encrypt/decrypt and validate ttl with AES-GCM 128/256 key size

  The block contains the following:
  version has 1 byte
  seconds in milis has 4 bytes (optional)
  IV has 12 bytes
  tag has 16 bytes
  ciphertext is the remaining
  """
  defmacro __using__(opts) do
    quote do
      opts = unquote(opts)
      @vsn Keyword.get(opts, :vsn, 0)
      @tag_bytes Keyword.get(opts, :tag_bytes, 16)
      @iv_bytes Keyword.get(opts, :iv_bytes, 12)
      @secret Keyword.get(opts, :secret)
      @algo_hash Keyword.get(opts, :algo, :sha256)
      @algo Keyword.get(opts, :algo, :aes_256_gcm)
      @max_age Keyword.get(opts, :max_age, 600)
      @tag_bits @tag_bytes * 8
      @iv_bits @iv_bytes * 8
      @key_size if(@algo == :aes_256_gcm, do: 32, else: 16)
      @time :seconds

      defmacro hash_key(key) do
        quote do
          key = unquote(key)
          size = byte_size(key)

          cond do
            size != @key_size ->
              :crypto.hash(@algo_hash, key)

            true ->
              key
          end
        end
      end

      def max_age, do: @max_age

      @doc """
      opts:
      key: secret-key
      iv: iv-bytes
      """
      @spec encrypt(binary, List.t()) :: binary | :error
      def encrypt(message, opts \\ []) do
        key = Keyword.get(opts, :key, @secret)
        iv = :crypto.strong_rand_bytes(@iv_bytes)
        key_hash = hash_key(key)

        seconds = encoded_seconds()

        result =
          :crypto.crypto_one_time_aead(@algo, key_hash, iv, message, seconds, @tag_bytes, true)

        case result do
          {ciphertext, tag} ->
            <<@vsn, seconds::binary, iv::binary, tag::binary, ciphertext::binary>>

          _ ->
            :error
        end
      end

      @doc """
      opts:
      key: secret-key
      max_age: seconds to expiry
      """
      @spec decrypt(binary, List.t()) :: binary | {:error, atom()}
      def decrypt(encodeText, opts) do
        key = Keyword.get(opts, :key, @secret)
        max_age = Keyword.get(opts, :age, @max_age)

        {ver, sec, iv, tag, ciphertext} = unpack_sec!(encodeText)
        key_hashed = hash_key(key)

        case validate_version(ver) do
          :bad_version ->
            {:error, :version}

          :ok ->
            case validate_ttl(sec, max_age) do
              :ok ->
                case :crypto.crypto_one_time_aead(
                       @algo,
                       key_hashed,
                       iv,
                       ciphertext,
                       sec,
                       tag,
                       false
                     ) do
                  :error ->
                    {:error, :decrypt}

                  result ->
                    result
                end

              _ ->
                {:error, :expire}
            end
        end
      end

      @doc """
      opts:
      key: secret-key
      max_age: seconds to expiry
      """
      @spec decrypt_ignore_time(binary, List.t()) :: {integer, boolean, term()} | :error
      def decrypt_ignore_time(encodeText, opts \\ []) do
        key = Keyword.get(opts, :key, @secret)
        max_age = Keyword.get(opts, :age, @max_age)

        {_ver, sec, iv, tag, ciphertext} = unpack_sec!(encodeText)
        key_hashed = hash_key(key)
        exp? = :ok == validate_ttl(sec, max_age)

        {sec, exp?,
         :crypto.crypto_one_time_aead(@algo, key_hashed, iv, ciphertext, sec, tag, false)}
      end

      def encrypt_string(data, opts \\ []) do
        data
        |> CBOR.encode()
        |> encrypt(opts)
        |> Base.encode64()
      end

      def decrypt_string(base64_string, opts \\ []) do
        result =
          Base.decode64!(base64_string)
          |> decrypt(opts)

        case result do
          {:error, _} ->
            :error

          data ->
            {:ok, values, _} = CBOR.decode(data)
            values
        end
      end

      def decrypt_decode(bin_string, opts \\ []) do
        result = decrypt(bin_string, opts)

        case result do
          :error ->
            :error

          data ->
            {:ok, values, _} = CBOR.decode(data)
            values
        end
      end

      @spec decrypt_string_ignore(binary, List.t()) :: {integer, boolean, term} | :error
      def decrypt_string_ignore(base64_string, opts \\ []) do
        {sec, exp?, result} =
          Base.decode64!(base64_string)
          |> decrypt_ignore_time(opts)

        case result do
          :error ->
            :error

          data ->
            {:ok, values, _} = CBOR.decode(data)
            {sec, exp?, values}
        end
      end

      @spec info(binary) :: term()
      def info(base64_string) do
        encodeText = Base.decode64!(base64_string)

        unpack_sec!(encodeText)
      end

      defp validate_ttl(_seconds, :infinity), do: :ok

      defp validate_ttl(seconds, ttl) do
        now = :erlang.system_time(@time)
        diff = now - decode_seconds(seconds)

        cond do
          diff < 0 ->
            :too_new

          diff >= 0 ->
            cond do
              ttl >= diff ->
                :ok

              ttl < diff ->
                :too_old
            end
        end
      end

      defp validate_version(@vsn), do: :ok
      defp validate_version(_), do: :bad_version

      # defp unpack!(<<version::8, iv::@iv_bits, tag::@tag_bits, ciphertext::binary>>),
      #   do: {version, <<iv::@iv_bits>>, <<tag::@tag_bits>>, ciphertext}

      defp unpack_sec!(<<version::8, sec::32, iv::@iv_bits, tag::@tag_bits, ciphertext::binary>>),
        do: {version, <<sec::32>>, <<iv::@iv_bits>>, <<tag::@tag_bits>>, ciphertext}

      defp encoded_seconds, do: :erlang.system_time(@time) |> :binary.encode_unsigned()

      defp decode_seconds(sec_bin), do: :binary.decode_unsigned(sec_bin)

      defp encode_token(encodeBytes), do: Base.encode64(encodeBytes)

      defp decode_token(encodeText), do: Base.decode64!(encodeText)
    end
  end
end
