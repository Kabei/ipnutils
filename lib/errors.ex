defmodule Ipnutils.Errors do
  import Ipnutils.Macros, only: [deferrors: 1]

  deferrors do
    [
      {400, "Bad Request"},
      {401, "Unauthorized"},
      {403, "Forbidden"},
      {404, "Not Found"},
      {405, "Not Allowed"},
      {40000, "Bad format"},
      {40100, "Invalid Block Version"},
      {40200, "Invalid Transaction Version"},
      {40201, "Invalid Transaction Type"},
      {40202, "Invalid Transaction time"},
      {40203, "Invalid Tx inputs"},
      {40204, "Invalid Tx outputs"},
      {40205, "Invalid Tx block index"},
      {40206, "Invalid Utxo"},
      {40207, "Invalid Total outputs"},
      {40208, "Invalid Transaccion size"},
      {40209, "Invalid Transaccion fees"},
      {40210, "Invalid Pubkey-Address"},
      {40211, "Invalid Sigs-Address"},
      {40212, "Invalid Signature"},
      {40213, "Invalid Token"},
      {40214, "Invalid Token Outputs"},
      {40215, "Invalid Address-Output size"},
      {40216, "Invalid Address type"},
      {40217, "Outputs exceeded"},
      {40218, "Inputs exceeded"},
      {40219, "Invalid refund"},
      {40220, "Invalid pool fees amount"},
      {40221, "The genesis block is not built"},
      {40222, "Token wrong ID type"},
      {40223, "Token symbol already used"},
      {40224, "Token wrong data"},
      {40225, "Invalid Token-Pubkey"},
      {40226, "Invalid core address"},
      {40227, "Invalid vote structure"},
      {40228, "Invalid signature in Vote"},
      {40229, "Transaction limit exceeded"},
      {40230, "Invalid channel format"},
      {40231, "Channel exists"},
      {40232, "Invalid Transaccion data size"},
      {40233, "Invalid Token symbol"},
      {40234, "Invalid Token decimal"},
      {40235, "Invalid Inputs and Outputs"},
      {40236, "Invalid Token-Fees"},
      {40237, "Invalid day to type transaction"},
      {50001, "Node offline"}
    ]
  else
    "Unknown"
  end
end
