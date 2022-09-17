defmodule Ipnutils.CubDB do
  require Logger
  @unit_time 1_000

  def unit_time, do: @unit_time

  def children(config) do
    blocks = config[:blocks] || []

    children =
      Enum.reduce(blocks, [], fn x, acc ->
        acc ++ child(x)
      end)

    check_expiry = config[:check_expiry] || 0

    if check_expiry > 0 do
      buckets_expiry =
        Enum.filter(blocks, fn x -> x.type in [:tmp, :tmpfs] end)
        |> Enum.map(fn x -> x.buckets end)
        |> Enum.concat()
        |> Enum.map(&String.to_atom(&1))

      spawn(__MODULE__, :check_expiry, [check_expiry, buckets_expiry])
    end

    children
  end

  @spec child(Map.t()) :: {list, list}
  def child(%{root: root_path, buckets: buckets, type: _type} = opts) do
    auto_compact = opts[:compress] || false

    for bucket_name <- buckets do
      atom_name = String.to_atom(bucket_name)

      bucket_path =
        root_path
        |> Path.expand()
        |> Path.join(bucket_name)

      arg = [data_dir: bucket_path, auto_compact: auto_compact, name: atom_name]
      Supervisor.child_spec({CubDB, arg}, id: {CubDB, atom_name})
    end
  end

  def check_expiry(time, buckets) do
    :timer.sleep(time)

    for bucket_atom <- buckets do
      Ipnutils.CubDB.delete_expired(bucket_atom)
    end

    check_expiry(time, buckets)
  end

  defmacro __using__(opts) do
    bucket_type = opts[:bucket_type] || :fs

    common =
      quote do
        opts = unquote(opts)
        @bucket opts[:bucket] |> String.to_atom()

        # common functions
        @spec keys :: list
        def keys do
          # Get a list of keys stored
          CubDB.select(@bucket, reverse: false)
          |> Stream.map(fn {key, _value} -> key end)
          |> Enum.to_list()
        end

        @spec select(term) :: {:ok, any}
        def select(select_opts) do
          CubDB.select(@bucket, select_opts)
        end

        @spec has_key?(term) :: boolean
        def has_key?(key) do
          CubDB.has_key?(@bucket, key)
        end

        @spec delete(term) :: :ok
        def delete(key) do
          CubDB.delete(@bucket, key)
        end

        @spec clear :: :ok
        def clear do
          CubDB.clear(@bucket)
        end

        def count(key, number) do
          amount = CubDB.get(@bucket, key, 0) + number

          CubDB.put(@bucket, key, amount)

          amount
        end

        def transaction(fun) do
          CubDB.transaction(@bucket, fun)
        end
      end

    specific =
      if bucket_type in [:fs, :ram] do
        quote do
          opts = unquote(opts)
          @bucket opts[:bucket] |> String.to_atom()

          @spec put(term, term) :: :ok
          def put(key, value) do
            CubDB.put(@bucket, key, value)
          end

          # put new value with random key
          @spec put_key(term) :: binary
          def put_key(val) do
            key =
              :crypto.strong_rand_bytes(10)
              |> Base62.encode()

            CubDB.put(@bucket, key, val)

            key
          end

          @spec get(term) :: term
          def get(key), do: CubDB.get(@bucket, key, nil)

          @spec get(term, term) :: term
          def get(key, default), do: CubDB.get(@bucket, key, default)

          @spec get(term) :: {:ok, term} | :error
          def fetch(key) do
            CubDB.fetch(@bucket, key)
          end

          @spec put_map(term, term, term) :: term
          def put_map(key, attr, value) do
            case CubDB.get(@bucket, key) do
              nil ->
                nil

              x when is_map(x) ->
                obj = Map.put(x, attr, value)
                CubDB.put(@bucket, key, obj)

              _data ->
                obj = Map.put(%{}, attr, value)
                CubDB.put(@bucket, key, obj)
            end
          end

          @spec push_item(term, term) :: term
          def push_item(key, new_value) do
            case CubDB.get(@bucket, key) do
              nil ->
                nil

              x when is_list(x) ->
                obj = x ++ [new_value]
                CubDB.put(@bucket, key, obj)

              x ->
                CubDB.put(@bucket, key, [x])
            end
          end
        end
      else
        quote do
          opts = unquote(opts)
          @bucket opts[:bucket] |> String.to_atom()
          @expiry opts[:expiry] || 120_000
          @unit_time Ipnutils.CubDB.unit_time()

          # temporal functions
          # put new value with random key
          @spec put_key(term, pos_integer) :: binary
          def put_key(val, expiry \\ @expiry) do
            key = :crypto.strong_rand_bytes(10) |> Base62.encode()

            CubDB.put(@bucket, key, {val, :erlang.system_time(@unit_time) + abs(expiry)})

            key
          end

          @spec put(term, term, pos_integer) :: :ok
          def put(key, value, expiry \\ @expiry) do
            CubDB.put(@bucket, key, {value, :erlang.system_time(@unit_time) + abs(expiry)})
          end

          @spec get(term) :: term
          def get(key) do
            now = :erlang.system_time(@unit_time)

            case CubDB.get(@bucket, key) do
              nil ->
                nil

              {value, time} ->
                if time > now do
                  value
                else
                  delete(key)
                  nil
                end

              value ->
                delete(key)
                nil
            end
          end

          @spec expires(term) :: integer
          def expires(key) do
            now = :erlang.system_time(@unit_time)

            case CubDB.get(@bucket, key) do
              nil ->
                0

              {_value, time} ->
                if time > now do
                  time - now
                else
                  delete(key)
                  0
                end

              value ->
                delete(key)
                0
            end
          end

          @spec check(term, term) :: boolean
          def check(key, val) do
            case get(key) do
              nil ->
                false

              object ->
                case object == val do
                  true ->
                    true

                  false ->
                    false
                end
            end
          end

          # compares the values once and deletes them
          @spec check_and_delete(term, term) :: boolean
          def check_and_delete(key, val) do
            case get(key) do
              nil ->
                false

              object ->
                case object == val do
                  true ->
                    CubDB.delete(@bucket, key)
                    true

                  false ->
                    false
                end
            end
          end
        end
      end

    [common, specific]
  end

  @spec delete_expired(atom()) :: {pos_integer(), list()} | :error
  def delete_expired(bucket) do
    now = :erlang.system_time(@unit_time)

    CubDB.select(bucket, reverse: false)
    |> Stream.filter(fn {_key, value} ->
      case value do
        {_x, time} when is_integer(time) and now > time ->
          true

        _ ->
          false
      end
    end)
    |> Stream.map(fn {key, _value} -> key end)
    |> Enum.to_list()
    |> case do
      [] ->
        {0, []}

      keys when is_list(keys) ->
        CubDB.delete_multi(bucket, keys)
        num = length(keys)
        Logger.debug("#{num} entries deleted from #{bucket}")
        {num, keys}

      _ ->
        :error
    end
  end
end
