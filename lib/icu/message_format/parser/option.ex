# defmodule Icu.MessageFormat.Parser.Option do
#   import NimbleParsec
#   alias Icu.MessageFormat.Parser.Utils, as: U

#   integer = ascii_string([?0..?9], min: 1) |> map({String, :to_integer, []})
#   literal = ignore(string("=")) |> concat(integer) |> unwrap_and_tag(:literal)

#   option =
#     U.seq([
#       literal |> unwrap_and_tag(:left),
#       "{",
#       parsec({Icu.MessageFormat.Parser, :message, []}) |> tag(:right)
#       "}"
#     ])

#   other_option =
#     U.seq([
#       string("other") |> replace(:other) |> unwrap_and_tag(:left),
#       "{",
#       parsec({Icu.MessageFormat.Parser, :message, []}) |> tag(:right)
#       "}"

#     ])

#   @literal literal

#   def literal_combinator() do
#     @literal
#   end

#   def option_combinator()
#   end

#   def other_option_combinator
# end
