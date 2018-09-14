defmodule INICollectorTest do
  @moduledoc false
  @module INI.Collector

  use INI.AST
  use ExUnit.Case

  describe "Will collect in a section namespace." do
    test "Collects an empty section." do
      ini =
        """
        [A]
        """

      %Environment{sections: sections} =
        @module.act ini

      assert match? [
        %Section{name: "A", children: []}
      ], sections
    end

    test "Collects a section with a pair." do
      ini =
        """
        [A]
        B=1
        """

      %Environment{sections: sections} =
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

      %Environment{sections: sections} =
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

      %Environment{sections: sections} =
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
  end

  describe "Will collect in the environmental namespace." do
    test "Collects a pair." do
      ini =
        """
        A=1
        """

      %Environment{state: state} =
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

      %Environment{state: state} =
        @module.act ini

      assert match? [
        %Pair{k: "A", v: "1"},
        %Pair{k: "B", v: "2"},
        %Pair{k: "C", v: "3"}
      ], state
    end

    test "Collects a pair with a \\n." do
      ini =
        """
        A=\
        1
        """

      %Environment{state: state} =
        @module.act ini

      assert match? [
        %Pair{k: "A", v: "1"}
      ], state
    end

    test "Collects a pair with subsequent \\n." do
      ini =
        """
        A=1\
        \
        2\
        \
        3
        """

      %Environment{state: state} =
        @module.act ini

      assert match? [
        %Pair{k: "A", v: "123"}
      ], state
    end

    test "Collects more than one pair whilst discarding redundant whitespace." do
      ini =
        """
        A = 1
        B   =   2
        C       =       3
        """

      %Environment{state: state} =
        @module.act ini

      match? [
        %Pair{k: "A", v: "1"},
        %Pair{k: "B", v: "2"},
        %Pair{k: "C", v: "3"}
      ], state
    end

    test "Collects a pair with subsequent \\n whilst discarding redundant whitespace." do
      ini =
        """
        A=\
        1\
         2\
          3\
        0  4
        """

      %Environment{state: state} =
        @module.act ini

      match? [
        %Pair{k: "A", v: "12304"}
      ], state
    end
  end
end
