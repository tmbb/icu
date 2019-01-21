defmodule Icu.MessageFormat.Parser.PluralArgument do
  import NimbleParsec

  alias Icu.MessageFormat.{
    PluralArgument,
    Variable,
    Option
  }

  alias Icu.MessageFormat.Parser.Utils

  def make_plural_argument({data, metadata}) do
    {raw_options, data} = Keyword.pop(data, :options)
    {offset, data} = Keyword.pop(data, :offset)
    {{variable_name, variable_metadata}, _data} = Keyword.pop(data, :variable)

    variable = Variable.new(name: variable_name, metadata: variable_metadata)

    options =
      for {option, option_metadata} <- raw_options do
        Option.new(value: option[:left], body: option[:right], metadata: option_metadata)
      end

    PluralArgument.new(
      variable: variable,
      options: options,
      offset: offset,
      metadata: metadata
    )
  end

  def combinator(message_combinator) do
    integer = ascii_string([?0..?9], min: 1) |> map({String, :to_integer, []})
    literal = ignore(string("=")) |> concat(integer) |> unwrap_and_tag(:literal)

    valid_option_names = ~w(zero one two few many)a

    valid_option =
      choice(
        for atom <- valid_option_names do
          binary = Atom.to_string(atom)
          string(binary) |> replace(atom)
        end
      )

    option =
      Utils.seq([
        choice([
          literal,
          valid_option
        ])
        |> unwrap_and_tag(:left),
        "{",
        message_combinator |> unwrap_and_tag(:right),
        "}"
      ])
      |> Utils.add_location()

    other_option =
      Utils.seq([
        string("other") |> replace(:other) |> unwrap_and_tag(:left),
        "{",
        message_combinator |> unwrap_and_tag(:right),
        "}"
      ])
      |> Utils.add_location()

    options =
      Utils.seq([
        Utils.zero_or_more(option),
        # The 'other' option is required
        other_option
      ])

    offset = ignore(string("offset:")) |> concat(integer)

    plural_argument =
      Utils.seq([
        "{",
        Utils.arg_name() |> Utils.unwrap_and_add_location() |> unwrap_and_tag(:variable),
        ",",
        "plural",
        ",",
        optional(offset |> unwrap_and_tag(:offset)),
        options |> tag(:options),
        "}"
      ])
      |> Utils.add_location()
      |> map({__MODULE__, :make_plural_argument, []})

    plural_argument
  end
end
