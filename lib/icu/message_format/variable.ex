defmodule Icu.MessageFormat.Variable do
  defstruct [
    :name,
    :metadata
  ]

  def new(opts) do
    struct(__MODULE__, opts)
  end
end
