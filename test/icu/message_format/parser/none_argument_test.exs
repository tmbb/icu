defmodule Icu.MessageFormat.Parser.NoneArgumentTest do
  use ExUnit.Case, async: true
  alias Icu.MessageFormat.Parser
  use ExUnitProperties

  describe "plural:" do
    property "recognizes variable" do
      check all first <- string([?a..?z], length: 1), rest <- string(:alphanumeric) do
        variable_name = first <> rest
        text = "{" <> variable_name <> "}"

        assert Parser.parse_message(text) ==
                 {:ok,
                  %Icu.MessageFormat.Message{
                    segments: [
                      %Icu.MessageFormat.NoneArgument{
                        metadata: %{line: 1, line_offset: 0, offset: 0},
                        variable: %Icu.MessageFormat.Variable{
                          metadata: %{line: 1, line_offset: 0, offset: 1},
                          name: variable_name
                        }
                      }
                    ]
                  }}
      end
    end
  end
end
