defmodule Icu.MessageFormat.Parser.NoneArgument do
  import NimbleParsec
  alias Icu.MessageFormat.Parser.Utils, as: U
  alias Icu.MessageFormat.Parser.Variable

  defstruct [
    :variable,
    :metadata
  ]

  def new(opts) do
    struct(__MODULE__, opts)
  end

  def make_none_arg({{variable_name, variable_metadata}, outer_metadata}) do
    variable = Variable.new(name: variable_name, metadata: variable_metadata)

    new(
      variable: variable,
      metadata: outer_metadata
    )
  end

  def combinator() do
    U.seq([
      "{",
      U.arg_name() |> U.unwrap_and_add_location(),
      "}"
    ])
    |> U.unwrap_and_add_location()
    |> map({__MODULE__, :make_none_arg, []})
  end
end
