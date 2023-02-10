defmodule Const.Regex do
  def only_digits, do: ~r/^[0-9]+$/

  def hex, do: ~r/^[0-9A-Fa-f]+$/

  def ip,
    do:
      ~r/((^\s*((([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))\s*$)|(^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$))/

  def email, do: ~r/^([a-z0-9]{1}[a-z0-9_.+-]{1,62}[a-z0-9]{1})@([a-z0-9]{1}[a-z0-9.-]{1,100}[a-z0-9]{1})$/

  def phone, do: ~r/^\+{1}[0-9]{11,15}$/

  def hostname,
    do:
      ~r/^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/

  def physical_address, do: ~r/^[#.0-9a-zA-Z\s,-]+$/

  # {28,38}
  def address, do: ~r/(1x)[1-9A-HJ-NP-Za-km-z]{1,}+$/

  def domain, do: ~r/^[A-Za-z0-9][A-Za-z0-9-]{1,61}[A-Za-z0-9]\.[A-Za-z]{1,}$/
  # def domain, do: ~r/^[a-z0-9]{0,1}[a-z0-9-]{0,61}[a-z0-9]{1,1}\.[a-z]{2,10}$/
  def ippan_domain,
    do:
      ~r/^[a-z0-9]{0,1}[a-z0-9-]{0,61}[a-z0-9]{1,1}\.(cmm|npo|ntw|cyber|ipn|wlt|iwl|ippan|btc|cyb|fin|geo|and|gold|god|lux|yes|bbb|i|u|btw|nws|diy|iot|69|opasy|ops|avatar|ultra|more|daddy|bro|sister|fck|tribe|mogul|tequila|gpt|soho|voice|eye|hodl|linux|youxi|we|genius|ciao|ok|dns|cyborg|replicant|air|amigo|bbq|burger|diamond|invest|jewel|pop|rap|rice|rod|soft|tkt|toy|vida|zoom|papi|hola|)$/

  def domain_link, do: ~r/^@([a-z0-9]{0,1}[a-z0-9-]{0,61}[a-z0-9]{1,1})/

  # def public_address, do: ~r/1[1-9A-HJ-NP-Za-km-z]{29,38}/
  def public_address, do: ~r/1x[1-9A-HJ-NP-Za-km-z]{1,}$/

  def private_address, do: ~r/2[1-9A-HJ-NP-Za-km-z]{1,}$/

  def combined_address, do: ~r/3[1-9A-HJ-NP-Za-km-z]{1,}$/

  def username, do: ~r/((?!^[\.\-\_])([a-z0-9\.\-\_])(?![\.\_\-][\.\_\-])(?![\.\-\_]$)){1,30}/

  def hashtag, do: ~r/(?:$|)#[A-Za-z0-9\-\.\_]+(?:$|)/

  def base58, do: ~r/^[1-9A-HJ-NP-Za-km-z]+$/

  def base62, do: ~r/^[0-9A-Za-z]+$/

  def base65, do: ~r/^[A-Za-z0-9\_\-\.]+$/

  def hash160, do: ~r/^[0-9A-Fa-f]{40}$/

  def hash256, do: ~r/^[0-9A-Fa-f]{64}$/

  def hash384, do: ~r/^[0-9A-Fa-f]{96}$/

  def hash512, do: ~r/^[0-9A-Fa-f]{128}$/

  def user_id, do: ~r/^(u-)[0-9A-Za-z]+$/

  @doc """
  delete after
  """
  def project_name, do: ~r/^[A-Za-z0-9]{1}[A-Za-z0-9\_\-\.]{0,15}[A-Za-z0-9]{1}$/

  def channel,
    do: ~r/(([A-Z]{2,5})\-([A-Z0-9]{2,5})\-([A-Z0-9]{2,5}))|(([A-Z]{2,5})\-([A-Z0-9]{2,5}))/

  # def token_fiat, do: ~r/^[A-Z]{3,10}/
  def token_currency, do: ~r/^[A-Z]{3,10}+$/
  def token_asset, do: ~r/^[0-9A-Za-z]{3,10}+$/
  def token_consumable, do: ~r/^(PDc-)[0-9A-Za-z]{5,24}+$/
  def token_unconsumable, do: ~r/^(PD-)[0-9A-Za-z]{4,24}+$/
  def token_unique, do: ~r/^(PDu-)[0-9A-Za-z]{5,24}+$/
  def token_expirable, do: ~r/^(PDe-)[0-9A-Za-z]{5,24}+$/
  def resize, do: ~r/^\d{1,4}$|^\d{1,4}x$|^x\d{1,4}$|^\d{1,4}x\d{1,4}$/

  def url do
    ~r/^(https?|ftp|file):\/\/[a-z0-9]{0,1}[a-z0-9-]{0,61}[a-z0-9]{1,1}\.[a-z]{1,}[-a-zA-Z0-9+&@#\/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#\/%=~_|]$/
  end
end
