defmodule Icu.MessageFormat.Parser.Variable do
  defstruct [
    :name,
    :metadata
  ]

  def new(opts) do
    struct(__MODULE__, opts)
  end
end
