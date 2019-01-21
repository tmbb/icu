defmodule Icu.MessageFormat.Message do
  defstruct segments: []

  def new(opts) do
    struct(__MODULE__, opts)
  end
end
