defmodule IcuTest do
  use ExUnit.Case
  doctest Icu

  test "greets the world" do
    assert Icu.hello() == :world
  end
end
