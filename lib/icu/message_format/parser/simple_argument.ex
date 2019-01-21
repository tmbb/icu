defmodule Icu.MessageFormat.Parser.SimpleArgument do
  defstruct [
    :type,
    :variable,
    :style,
    :metadata
  ]

  def new(opts) do
    struct(__MODULE__, opts)
  end
end
