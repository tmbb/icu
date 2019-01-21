defmodule Icu.MessageFormat.Parser.Utils do
  @moduledoc false
  import NimbleParsec

  alias Icu.MessageFormat.Parser.{
    SimpleArgument,
    Variable,
    Style
  }

  def add_location(combinator) do
    pre_traverse(combinator, {__MODULE__, :__add_location__, []})
  end

  def unwrap_and_add_location(combinator) do
    pre_traverse(combinator, {__MODULE__, :__unwrap_and_add_location__, []})
  end

  @doc false
  def __unwrap_and_add_location__(_rest, [arg], context, line, offset) do
    {line_nr, column_bytes} = line
    metadata = %{line: line_nr, column_bytes: column_bytes, offset: offset}
    {[{arg, metadata}], context}
  end

  @doc false
  def __add_location__(_rest, args, context, line, offset) do
    {line_nr, column_bytes} = line
    metadata = %{line: line_nr, column_bytes: column_bytes, offset: offset}
    {[{args, metadata}], context}
  end

  def arg_name() do
    ascii_char([?a..?z])
    |> repeat(ascii_char([?a..?z, ?A..?Z, ?0..?9, ?_]))
    |> reduce({List, :to_string, []})
  end

  def message_text() do
    utf8_string([not: ?{, not: ?}], min: 1)
  end

  def message_text_inside_plural() do
    utf8_string([not: ?{, not: ?}, not: ?#], min: 1)
  end

  @doc """
  An sequence of optional whitespace.
  """
  def whitespace() do
    repeat(ascii_char([?\s, ?\t, ?\f, ?\n, ?\r]))
  end

  @doc """
  A sequence of combinators separated by optional whitespace.
  """
  def seq(combinators) do
    with_wrapped_raw_strings =
      Enum.map(combinators, fn
        # If the "combinator" is just a binary, wrap it and ignore it
        comb when is_binary(comb) -> ignore(string(comb))
        # Otherwise, return the combinator unchanged
        comb -> comb
      end)

    separated_by_whitespace =
      with_wrapped_raw_strings
      |> Enum.intersperse(ignore(whitespace()))
      |> Enum.reverse()

    Enum.reduce(separated_by_whitespace, &concat/2)
  end

  @doc """
  Repeat a combinator one or more times, separated by optional whitespace.
  """
  def one_or_more(combinator) do
    combinator
    |> repeat(ignore(whitespace()) |> concat(combinator))
  end

  def arg_style(options, extra \\ []) do
    fixed_options =
      for atom_option <- options do
        string_option = Atom.to_string(atom_option)

        string(string_option) |> replace(atom_option)
      end

    all_choices = fixed_options ++ extra

    choice(all_choices)
  end

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

  def simple_arg(name, arg_style) do
    atom_name = String.to_atom(name)

    head = [
      "{",
      arg_name() |> unwrap_and_add_location() |> unwrap_and_tag(:variable),
      ",",
      name
    ]

    middle =
      if arg_style do
        [
          optional(
            seq([
              ",",
              arg_style |> unwrap_and_add_location() |> unwrap_and_tag(:style)
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
    |> seq()
    |> add_location()
    |> map({__MODULE__, :make_simple_arg, [atom_name]})
  end
end
