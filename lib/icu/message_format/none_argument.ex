defmodule Icu.MessageFormat.NoneArgument do
  import NimbleParsec
  alias Icu.MessageFormat.Parser.Utils, as: U
  alias Icu.MessageFormat.Variable

  defstruct [
    :variable,
    :metadata
  ]

  def new(opts) do
    struct(__MODULE__, opts)
  end
end
