defmodule Icu.MessageFormat.Parser do
  import NimbleParsec
  alias Icu.MessageFormat.Parser.Utils, as: U

  # argument_number is not supported by design!

  currency_code = utf8_string([not: ?{, not: ?}, not: ?\s], min: 1)

  currency =
    choice([
      # Currency with code
      replace(string("currency"), :currency)
      |> ignore(string(":"))
      |> concat(currency_code)
      |> reduce({List, :to_tuple, []}),
      # Currency without code
      replace(string("currency"), :currency)
    ])

  number_arg_style = U.arg_style(~w(integer percent)a, [currency])
  date_arg_style = U.arg_style(~w(short medium long full)a)
  time_arg_style = U.arg_style(~w(short medium long full)a)
  spellout_arg_style = nil
  ordinal_arg_style = nil
  duration_arg_style = nil

  none_arg = U.seq(["{", unwrap_and_tag(U.arg_name(), :variable), "}"]) |> tag(:none)

  number_arg = U.simple_arg("number", number_arg_style)
  date_arg = U.simple_arg("date", date_arg_style)
  time_arg = U.simple_arg("time", time_arg_style)
  spellout_arg = U.simple_arg("spellout", spellout_arg_style)
  ordinal_arg = U.simple_arg("ordinal", ordinal_arg_style)
  duration_arg = U.simple_arg("duration", duration_arg_style)

  simple_arg = [
    number_arg,
    date_arg,
    time_arg,
    spellout_arg,
    ordinal_arg,
    duration_arg
  ]

  complex_arg = [
    # plural_arg,
    # select_arg,
    # selectordinal_arg
  ]

  argument = choice([none_arg] ++ simple_arg ++ complex_arg)

  message =
    repeat(
      choice([
        U.message_text(),
        argument
      ])
    )

  defparsec(:message, message)
end
