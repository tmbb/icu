defmodule Icu.MessageFormat.SelectArgument do
  defstruct variable: nil,
            options: nil

  def new(opts) do
    struct(__MODULE__, opts)
  end
end
