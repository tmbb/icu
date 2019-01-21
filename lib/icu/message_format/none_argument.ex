defmodule Icu.MessageFormat.NoneArgument do
  defstruct [
    :variable,
    :metadata
  ]

  def new(opts) do
    struct(__MODULE__, opts)
  end
end
