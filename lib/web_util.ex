# defmodule WebUtils do
#   import Ipnutils.Errors, only: [msg: 1]
#   require Logger

#   @compile {:inline, send_resp: 2, send_resp: 3, send_resp: 4, send_error: 2, json: 2, json: 3}
#   @json Application.get_env(:ipnutils, :jsonlib, Jason)
#   @header_text %{"content-type" => "text/plain"}
#   @header_json %{"content-type" => "application/json; charset=utf-8"}

#   def json(req, body) do
#     :cowboy_req.reply(200, @header_json, @json.encode(body), req)
#   end

#   def json(req, status, body) do
#     :cowboy_req.reply(status, @header_json, @json.encode(body), req)
#   end

#   def send_resp(req, code, headers \\ %{}) do
#     :cowboy_req.reply(code, headers, req)
#   end

#   def send_resp(req, code, headers, body) do
#     :cowboy_req.reply(code, headers, body, req)
#   end

#   def send_error(req, code) do
#     :cowboy_req.reply(400, @header_text, msg(code), req)
#   end

#   def read_query(req) do
#     Enum.into(:cowboy_req.parse_qs(req), %{})
#   end

#   def read_json(%{body_length: 0}), do: %{}
#   # def read_json(%{body_length: len}) when len > 65_536, do: throw(:excedeed_json_body)

#   def read_json(req) do
#     {:ok, data, _req} = :cowboy_req.read_body(req)
#     @json.decode!(data)
#   end

#   def send_json(req, data) do
#     send_resp(req, 200, @header_json, @json.encode!(data))
#   end

#   def catch_resp_json(x, req) do
#     case x do
#       :ok ->
#         Logger.debug("ok")
#         send_resp(req, 200)

#       nil ->
#         Logger.debug("Empty")
#         send_resp(req, 204)

#       [] ->
#         Logger.debug("Empty")
#         send_resp(req, 204)

#       {:ok, []} ->
#         Logger.debug("Empty")
#         send_resp(req, 204)

#       {:ok, data} ->
#         Logger.debug("Success: " <> inspect(data))
#         send_resp(req, 200, @header_json, @json.encode!(data))

#       {:created, data} ->
#         Logger.debug("Created: " <> inspect(data))
#         send_resp(req, 201, @header_json, @json.encode!(data))

#       {:error, code} ->
#         IO.puts("Error: " <> inspect(code))
#         send_error(req, code)

#       data ->
#         Logger.debug("Success: " <> inspect(data))
#         send_resp(req, 200, @header_json, @json.encode!(data))
#     end
#   end
# end
