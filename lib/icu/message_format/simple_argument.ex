defmodule Icu.MessageFormat.SimpleArgument do
  defstruct type: nil, style: nil, variable: nil, metadata: nil

  def new(opts) do
    struct(__MODULE__, opts)
  end
end
