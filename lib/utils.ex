defmodule Utils do
  @spec cast_bool(nil | number() | binary()) :: boolean()
  def cast_bool(nil), do: false
  def cast_bool(false), do: false
  def cast_bool(true), do: true
  def cast_bool(0), do: false
  def cast_bool(1), do: true
  def cast_bool(0.0), do: false
  def cast_bool(1.0), do: true
  def cast_bool(<<>>), do: false

  def cast_bool(x) when is_binary(x) do
    case :string.uppercase(x) do
      "T" ->
        true

      "Y" ->
        true

      "YES" ->
        true

      "TRUE" ->
        true

      _ ->
        false
    end
  end

  def cast_bool(_), do: false

  @spec normalize(nil | binary()) :: binary()
  def normalize(nil), do: <<>>
  def normalize(data), do: data

  @spec array_normalize(any()) :: list()
  def array_normalize(data) when not is_list(data), do: []
  def array_normalize(data), do: data

  def is_empty(nil), do: true
  def is_empty([]), do: true
  def is_empty(_), do: false

  def decode16(nil), do: <<>>

  def decode16(data) do
    try do
      Base.decode16!(data, case: :mixed)
    rescue
      ArgumentError ->
        data
    end
  end

  def decode64(nil), do: <<>>

  def decode64(data) do
    try do
      Base.decode64!(data)
    rescue
      ArgumentError ->
        data
    end
  end

  def from_date_to_time(date, :start, unit_time) when is_binary(date) do
    d = DateTime.from_iso8601(date <> "T00:00:00Z")

    case d do
      {:error, _} ->
        nil

      {:ok, dt, _} ->
        DateTime.to_unix(dt, unit_time)
    end
  end

  def from_date_to_time(date, :end, unit_time) when is_binary(date) do
    d = DateTime.from_iso8601(date <> "T23:59:59Z")

    case d do
      {:error, _} ->
        nil

      {:ok, dt, _} ->
        DateTime.to_unix(dt, unit_time)
    end
  end

  def from_date_to_time(_date, _range, _unit_time), do: nil

  # def cast_integer(val), do: cast_integer(val, nil)

  # def cast_integer(nil, default), do: default
  # def cast_integer([], default), do: default
  # def cast_integer(%{}, default), do: default

  # def cast_integer(val, _default) when is_integer(val), do: val
  # def cast_integer(val, _default) when is_float(val), do: trunc(val)

  # def cast_integer(val, default) when is_binary(val) do
  #   try do
  #     String.to_integer(val)
  #   rescue
  #     ArgumentError ->
  #       default
  #   end
  # end

  # def cast_integer(val, _default), do: val

  # def cast_date(nil), do: nil

  # def cast_date(date, default) do
  #   case Date.from_iso8601(date) do
  #     {:error, _} ->
  #       default

  #     {:ok, response} ->
  #       response
  #   end
  # end
end
