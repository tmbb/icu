defmodule Icu.MessageFormat.SelectOrdinalArgument do
  defstruct variable: nil,
            options: nil,
            offset: nil

  def new(opts) do
    struct(__MODULE__, opts)
  end
end
