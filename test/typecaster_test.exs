defmodule INITypecasterTest do
  @moduledoc false
  @module INI.Typecaster

  use INI.AST
  use ExUnit.Case

  describe "Will typecast integers, floats, boolean and binaries." do
    test "Will typecast an integer." do
      ast =
        %{%Environment{}
          | state: [
            %Pair{k: "A", v: "1"}
          ]
        }

      %{state: state} =
        @module.act ast

      assert match? [
        %Pair{k: "A", v: 1}
      ], state
    end

    test "Will typecast an integer with trailing characters." do
      ast =
        %{%Environment{}
          | state: [
            %Pair{k: "A", v: "1 TRAILING"}
          ]
        }

      %{state: state} =
        @module.act ast

      assert match? [
        %Pair{k: "A", v: 1}
      ], state
    end

    test "Will typecast a float." do
      ast =
        %{%Environment{}
          | state: [
            %Pair{k: "A", v: "1.0"}
          ]
        }

      %{state: state} =
        @module.act ast

      assert match? [
        %Pair{k: "A", v: 1.0}
      ], state
    end

    test "Will typecast a float with trailing characters." do
      ast =
        %{%Environment{}
          | state: [
            %Pair{k: "A", v: "1.0 TRAILING"}
          ]
        }

      %{state: state} =
        @module.act ast

      assert match? [
        %Pair{k: "A", v: 1.0}
      ], state
    end

    test "Will typecast a boolean." do
      ast =
        %{%Environment{}
          | state: [
            %Pair{k: "A", v: "true"}
          ]
        }

      %{state: state} =
        @module.act ast

      assert match? [
        %Pair{k: "A", v: true}
      ], state
    end

    test "Will typecast a binary." do
      ast =
        %{%Environment{}
          | state: [
            %Pair{k: "A", v: "Here be dragons."}
          ]
        }

      %{state: state} =
        @module.act ast

      assert match? [
        %Pair{k: "A", v: "Here be dragons."}
      ], state
    end

    test "Will typecast a quoted binary." do
      ast =
        %{%Environment{}
          | state: [
            %Pair{k: "A", v: "\"   We want to maintain the \\\nmarkup, but lose the quotes.\""}
          ]
        }

      %{state: state} =
        @module.act ast

      assert match? [
        %Pair{k: "A", v: "   We want to maintain the \\\nmarkup, but lose the quotes."}
      ], state
    end
  end
end
