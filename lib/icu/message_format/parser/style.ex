defmodule Icu.MessageFormat.Parser.Style do
  defstruct [
    :value,
    :metadata
  ]

  def new(opts) do
    struct(__MODULE__, opts)
  end
end
