defmodule Icu.MessageFormat.Option do
  defstruct value: nil, body: nil, metadata: nil

  def new(opts) do
    struct(__MODULE__, opts)
  end
end
