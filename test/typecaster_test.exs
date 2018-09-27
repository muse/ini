defmodule INITypecasterTest do
  @moduledoc false
  @module INI.Typecaster

  use INI.AST
  use ExUnit.Case

  describe "Will typecast integers, floats, boolean and binaries." do
    test "Will typecast an integer." do
      ast =
        %{%Env{}
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
        %{%Env{}
          | state: [
            %Pair{k: "A", v: "1 <Trailing characters>"}
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
        %{%Env{}
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
        %{%Env{}
          | state: [
            %Pair{k: "A", v: "1.0 <Trailing characters>"}
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
        %{%Env{}
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
        %{%Env{}
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
        %{%Env{}
          | state: [
            %Pair{k: "A", v: "\"   We want to maintain the \\nmarkup, but lose the quotes.\""}
          ]
        }

      %{state: state} =
        @module.act ast

      assert match? [
        %Pair{k: "A", v: "   We want to maintain the \\nmarkup, but lose the quotes."}
      ], state
    end

    test "Will typecast a value within a section" do
      ast =
        %{%Env{}
          | sections: [
            %Section{
              children: [
                %Pair{k: "A", v: "1"},
                %Pair{k: "B", v: "1.0"},
                %Pair{k: "C", v: "0.5"}
              ]
            }
          ]
        }

      %{sections: sections} =
        @module.act ast

      assert match? [
        %Section{
          children: [
            %Pair{k: "A", v: 1},
            %Pair{k: "B", v: 1.0},
            %Pair{k: "C", v: 0.5}
          ]
        }
      ], sections
    end
  end
end
