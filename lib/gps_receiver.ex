defmodule GpsReceiver do
  @compile {:inline, exists?: 0, exists?: 1}

  @device Application.get_env(:ipncore, :gps_device)

  def exists?(), do: exists?(@device)
  def exists?(nil), do: false

  def exists?(device_path) do
    File.exists?(device_path)
  end

  @spec get_time(device_path :: String.t()) :: {:ok, DateTime.t()} | {:error, atom()}
  def get_time(device_path \\ @device) do
    port = Port.open({:spawn, "cat"}, [:binary])
    send(port, {self(), {:command, "#{device_path} | grep GPRMC"}})

    result =
      receive do
        {:data, value} ->
          try do
            gprmc =
              value
              |> String.split("$GPRMC,")
              |> List.last()

            [time, _, _, _, _, _, _, _, date, _, _, _] =
              gprmc
              |> String.split(",")

            <<shour::bytes-size(2), smin::bytes-size(2), ssec::bytes-size(2), _dot::bytes-size(1),
              smillis::binary>> = time

            <<sday::bytes-size(2), smonth::bytes-size(2), syear::binary>> = date

            hour = String.to_integer(shour)
            min = String.to_integer(smin)
            sec = String.to_integer(ssec)
            millis = String.to_integer(smillis)

            year = String.to_integer(syear)
            month = String.to_integer(smonth)
            day = String.to_integer(sday)

            t = Time.new!(hour, min, sec, millis)

            now = Date.utc_today()
            sum_year = now.year - rem(now.year, 100)
            d = Date.new!(sum_year + year, month, day)

            DateTime.new!(d, t)
          rescue
            MatchError ->
              {:error, :match}

            ErlangError ->
              {:error, :unknown}
          end

        _ ->
          IO.puts(:stderr, "Unexpected message gps received")
          {:error, :unexpected}
      after
        5_000 ->
          {:error, :timeout}
      end

    Port.close(port)

    result
  end
end
