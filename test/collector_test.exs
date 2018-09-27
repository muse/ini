defmodule INICollectorTest do
  @moduledoc false
  @module INI.Collector

  use INI.AST
  use ExUnit.Case

  describe "Will collect a section." do
    test "Collects an empty section." do
      ini =
        """
        [A]
        """

      %Env{sections: sections} =
        @module.act ini

      assert match? [
        %Section{name: "A", children: []}
      ], sections
    end

    test "Collects multiple empty sections." do
      ini =
        """
        [A]
        [B]
        [C]
        """

      %Env{sections: sections} =
        @module.act ini

      assert match? [
        %Section{name: "A", children: []},
        %Section{name: "B", children: []},
        %Section{name: "C", children: []}
      ], sections
    end

    test "Collects a section with a pair." do
      ini =
        """
        [A]
        B=1
        """

      %Env{sections: sections} =
        @module.act ini

      assert match? [
        %Section{name: "A", children: [
          %Pair{k: "B", v: "1"}
        ]}
      ], sections
    end

    test "Collects a section with a pair on one line." do
      ini =
        """
        [A]B=1
        """

      %Env{sections: sections} =
        @module.act ini

      assert match? [
        %Section{name: "A", children: [
          %Pair{k: "B", v: "1"}
        ]}
      ], sections
    end

    test "Collects a section with more than one pair." do
      ini =
        """
        [A]
        B=1
        C=2
        """

      %Env{sections: sections} =
        @module.act ini

      assert match? [
        %Section{name: "A", children: [
          %Pair{k: "B", v: "1"},
          %Pair{k: "C", v: "2"}
        ]}
      ], sections
    end

    test "Collects more than one section with more than one pair in each of them." do
      ini =
        """
        [A]
        B=1
        C=2
        [D]
        E=3
        F=4
        """

      %Env{sections: sections} =
        @module.act ini

      assert match? [
        %Section{name: "A", children: [
          %Pair{k: "B", v: "1"},
          %Pair{k: "C", v: "2"}
        ]},
        %Section{name: "D", children: [
          %Pair{k: "E", v: "3"},
          %Pair{k: "F", v: "4"}
        ]}
      ], sections
    end

    test "Collects a section whilst skipping comments." do
      ini =
        """
        ; This is section A
        ; This section is useful because it has the value `A`.
        [A]
        ; I like A.
        """

      %Env{sections: sections} =
        @module.act ini

      assert match? [
        %Section{name: "A", children: []}
      ], sections
    end

    test "Collects a section with a pair whist skipping comments." do
      ini =
        """
        ; We've section A here once more.
        [A]
        ; Section A harbours the pair B = 1.
        B = 1
        ; We now know that B is 1.
        """

      %Env{sections: sections} =
        @module.act ini

      assert match? [
        %Section{name: "A", children: [
          %Pair{k: "B", v: "1"}
        ]}
      ], sections


    end
  end

  describe "Will collect a pair [value]." do
    test "Collects a pair." do
      ini =
        """
        A=1
        """

      %Env{state: state} =
        @module.act ini

      assert match? [
        %Pair{k: "A", v: "1"}
      ], state
    end

    test "Collects more than one pair." do
      ini =
        """
        A=1
        B=2
        C=3
        """

      %Env{state: state} =
        @module.act ini

      assert match? [
        %Pair{k: "A", v: "1"},
        %Pair{k: "B", v: "2"},
        %Pair{k: "C", v: "3"}
      ], state
    end

    test "Collects a pair with no value." do
      ini =
        """
        A
        """

      %Env{state: state} =
        @module.act ini

      assert match? [
        %Pair{k: "A", v: ""}
      ], state
    end

    test "Collects more than one pair with no value." do
      ini =
        """
        A
        B
        C
        """

      %Env{state: state} =
        @module.act ini

      assert match? [
        %Pair{k: "A", v: ""},
        %Pair{k: "B", v: ""},
        %Pair{k: "C", v: ""}
      ], state
    end

    test "Collects a pair with subsequent newlines." do
      ini =
        """
        A=\
        \
        1

        A\
        B\
        C=6
        """

      %Env{state: state} =
        @module.act ini

      assert match? [
        %Pair{k: "A", v: "1"},
        %Pair{k: "ABC", v: "6"}
      ], state


    end

    test "Collects a pair with subsequent newlines whilst discarding redundant whitespace." do
      ini =
        """
        A \
          \
          = \
          \
          \
        1
        """

      %Env{state: state} =
        @module.act ini

      assert match? [
        %Pair{k: "A", v: "1"},
      ], state
    end

    test "Collects more than one pair whilst discarding redundant whitespace." do
      ini =
        """
        A \
          \
        = \
          \
        1

        B = \
            \
            2
        """

      %Env{state: state} =
        @module.act ini

      assert match? [
        %Pair{k: "A", v: "1"},
        %Pair{k: "B", v: "2"},
      ], state
    end

    test "Collects a pair with a quoted binary." do
      ini =
        """
        A = \
          " -- We are alive, sentient beings are amongst us. -- "
        """

      %Env{state: state} =
        @module.act ini

      assert match? [
        %Pair{k: "A", v: "\" -- We are alive, sentient beings are amongst us. -- \""}
      ], state
    end

    test "Collects a pair with unambigious UTF8 characters." do
      ini =
        """
        A = 1

        Ѭ = 1
        2 = Ԫ
        ࢉ = 3
        """

      %Env{state: state} =
        @module.act ini

      assert match? [
        %Pair{k: "A", v: "1"},
        %Pair{k: <<209>>, v: "1"},
        %Pair{k: "2", v: <<212>>},
        %Pair{k: <<224>>, v: "3"}
      ], state
    end
  end
end
