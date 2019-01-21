defmodule Icu.MessageFormat.Parser.SimpleArgument do
  import NimbleParsec
  alias Icu.MessageFormat.Parser.Utils, as: U
  alias Icu.MessageFormat.{Variable, Style, SimpleArgument}

  def make_simple_arg({data, metadata}, type) do
    style =
      case Keyword.get(data, :style) do
        {style_value, style_metadata} ->
          Style.new(value: style_value, metadata: style_metadata)

        nil ->
          nil
      end

    {variable_name, variable_metadata} = Keyword.get(data, :variable)
    variable = Variable.new(name: variable_name, metadata: variable_metadata)

    SimpleArgument.new(
      type: type,
      style: style,
      variable: variable,
      metadata: metadata
    )
  end

  def combinator(atom_name, arg_style) do
    name = Atom.to_string(atom_name)

    head = [
      "{",
      U.arg_name() |> U.unwrap_and_add_location() |> unwrap_and_tag(:variable),
      ",",
      name
    ]

    middle =
      if arg_style do
        [
          optional(
            U.seq([
              ",",
              arg_style |> U.unwrap_and_add_location() |> unwrap_and_tag(:style)
            ])
          )
        ]
      else
        []
      end

    tail = [
      "}"
    ]

    (head ++ middle ++ tail)
    |> U.seq()
    |> U.add_location()
    |> map({__MODULE__, :make_simple_arg, [atom_name]})
  end
end
