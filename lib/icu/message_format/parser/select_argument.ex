defmodule Icu.MessageFormat.Parser.SelectArgument do
  import NimbleParsec

  alias Icu.MessageFormat.{
    SelectArgument,
    Variable,
    Option
  }

  alias Icu.MessageFormat.Parser.Utils

  def make_select_argument({data, metadata}) do
    {raw_options, data} = Keyword.pop(data, :options)
    {{variable_name, variable_metadata}, _data} = Keyword.pop(data, :variable)

    variable = Variable.new(name: variable_name, metadata: variable_metadata)

    options =
      for {option, option_metadata} <- raw_options do
        Option.new(value: option[:left], body: option[:right], metadata: option_metadata)
      end

    SelectArgument.new(
      variable: variable,
      options: options,
      metadata: metadata
    )
  end

  def combinator(message_combinator) do
    valid_option =
      lookahead_not(string("other"))
      # TODO: what's the grammar for this?!
      |> ascii_string([?a..?z, ?A..?Z, ?0..?9, ?_], min: 1)

    option =
      Utils.seq([
        valid_option |> unwrap_and_tag(:left),
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

    select_argument =
      Utils.seq([
        "{",
        Utils.arg_name() |> Utils.unwrap_and_add_location() |> unwrap_and_tag(:variable),
        ",",
        "select",
        ",",
        options |> tag(:options),
        "}"
      ])
      |> Utils.add_location()
      |> map({__MODULE__, :make_select_argument, []})

    select_argument
  end
end
