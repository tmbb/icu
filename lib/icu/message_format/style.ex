defmodule Icu.MessageFormat.Style do
  defstruct [
    :value,
    :metadata
  ]

  def new(opts) do
    struct(__MODULE__, opts)
  end
end
