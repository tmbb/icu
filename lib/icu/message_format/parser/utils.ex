defmodule Icu.MessageFormat.Parser.Utils do
  @moduledoc false
  import NimbleParsec

  def add_location(combinator) do
    pre_traverse(combinator, {__MODULE__, :__add_location__, []})
  end

  def unwrap_and_add_location(combinator) do
    pre_traverse(combinator, {__MODULE__, :__unwrap_and_add_location__, []})
  end

  @doc false
  def __unwrap_and_add_location__(_rest, [arg], context, line, offset) do
    {line_nr, line_offset} = line
    metadata = %{line: line_nr, line_offset: line_offset, offset: offset}
    {[{arg, metadata}], context}
  end

  @doc false
  def __add_location__(_rest, args, context, line, offset) do
    {line_nr, line_offset} = line
    metadata = %{line: line_nr, line_offset: line_offset, offset: offset}
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

  def zero_or_more(combinator) do
    combinator
    |> repeat(ignore(whitespace()) |> concat(combinator))
    |> optional()
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
end
