defmodule Icu.MessageFormat.Parser.SimpleArgument.Currency do
  import NimbleParsec

  def combinator() do
    currency_code = utf8_string([not: ?{, not: ?}, not: ?\s], min: 1)

    choice([
      # Currency with code
      replace(string("currency"), :currency)
      |> ignore(string(":"))
      |> concat(currency_code)
      |> reduce({List, :to_tuple, []}),
      # Currency without code
      replace(string("currency"), :currency)
    ])
  end
end
