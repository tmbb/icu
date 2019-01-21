defmodule Icu.MessageFormat.Parser do
  import NimbleParsec
  alias Icu.MessageFormat.Parser.Utils, as: U

  alias Icu.MessageFormat.Parser.{
    NoneArgument,
    SimpleArgument,
    PluralArgument,
    SelectArgument,
    SelectOrdinalArgument
  }

  alias SimpleArgument.Currency

  alias Icu.MessageFormat.Message

  # numbered arguments (instead of named arguments) are not supported by design!

  number_arg_style = U.arg_style(~w(integer percent)a, [Currency.combinator()])
  date_arg_style = U.arg_style(~w(short medium long full)a)
  time_arg_style = U.arg_style(~w(short medium long full)a)
  spellout_arg_style = nil
  ordinal_arg_style = nil
  duration_arg_style = nil

  none_arg = NoneArgument.combinator()

  number_arg = SimpleArgument.combinator(:number, number_arg_style)
  date_arg = SimpleArgument.combinator(:date, date_arg_style)
  time_arg = SimpleArgument.combinator(:time, time_arg_style)
  spellout_arg = SimpleArgument.combinator(:spellout, spellout_arg_style)
  ordinal_arg = SimpleArgument.combinator(:ordinal, ordinal_arg_style)
  duration_arg = SimpleArgument.combinator(:duration, duration_arg_style)

  simple_arg = [
    number_arg,
    date_arg,
    time_arg,
    spellout_arg,
    ordinal_arg,
    duration_arg
  ]

  plural_arg = PluralArgument.combinator(parsec(:message))
  select_arg = SelectArgument.combinator(parsec(:message))
  selectordinal_arg = SelectOrdinalArgument.combinator(parsec(:message))

  complex_arg = [
    plural_arg,
    select_arg,
    selectordinal_arg
  ]

  argument = choice([none_arg] ++ simple_arg ++ complex_arg)

  message =
    repeat(
      choice([
        U.message_text(),
        argument
      ])
    )
    |> reduce({__MODULE__, :make_message, []})

  def make_message(segments) do
    Message.new(segments: segments)
  end

  # Parses a message which may or may not be only part of the string
  defparsec(:message, message)

  # parses a complete stringa as a message
  defparsec(:full_message, parsec(:message) |> eos())

  def parse_message(text) do
    case full_message(text) do
      {:ok, [message], "", _, _, _} ->
        {:ok, message}

      {:error, error_message, _, _, _} ->
        {:error, error_message}
    end
  end
end
