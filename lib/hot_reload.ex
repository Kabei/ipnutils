# defmodule HotReload do
#   def load(modules) when is_list(modules) do
#     for x when is_atom(x) <- modules do
#       :code.purge(x)
#       :code.load_file(x)
#     end
#   end

#   def decompress(file_path) do
#     target_decompress = ""
#     {_, 0} = System.cmd("unzip", ["#{file_path}", "#{target_decompress}"])
#     {_, 0} = System.cmd("mv", ["-f", "source", "target"])

#     binary = File.read!(Path.join(target_decompress, "modules.info"))

#     :erlang.binary_to_term(binary)
#   end

#   def check_version(version) do
#     Const.System.version() == version
#   end

#   def check_hash(file_path, hash) do
#     Crypto.hash_file(file_path) == hash
#   end
# end
