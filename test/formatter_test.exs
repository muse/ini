defmodule INIFormatterTest do
  @moduledoc false
  @module INI.Formatter

  use INI.AST
  use ExUnit.Case




  describe "Will format a section" do
    test "Will format an empty section." do
      ast =
        %Env{
          state: [
            %Section{
              name: "A"
            }
          ]
        }

      fmt =
        @module.act ast

      assert match? ^fmt,
        """
        [A]
        """
    end

    test "Will format multiple empty sections." do
      ast =
        %Env{
          state: [
            %Section{
              name: "A"
            },
            %Section{
              name: "B"
            },
            %Section{
              name: "C"
            }
          ]
        }

      fmt =
        @module.act ast

      assert match? ^fmt,
        """
        [A]

        [B]

        [C]
        """
    end

    test "Will format a section with a pair." do
      ast =
        %Env{
          state: [
            %Section{
                  name: "A",
              children: [
                %Pair{
                  k: "B",
                  v: "1"
                }
              ]
            }
          ]
        }

      fmt =
        @module.act ast

      assert match? ^fmt,
        """
        [A]
        B = 1
        """
    end

    test "Will format a section with more than one pair." do
      ast =
        %Env{
          state: [
            %Section{
                  name: "A",
              children: [
                %Pair{
                  k: "B",
                  v: "1"
                },
                %Pair{
                  k: "C",
                  v: "2"
                }
              ]
            }
          ]
        }

      fmt =
        @module.act ast

      assert match? ^fmt,
        """
        [A]
        B = 1
        C = 2
        """
    end

    test "Will format more than one section with more than one pair in each of them." do
      ast =
        %Env{
          state: [
            %Section{
                  name: "A",
              children: [
                %Pair{
                  k: "B",
                  v: "1"
                },
                %Pair{
                  k: "C",
                  v: "2"
                }
              ]
            },
            %Section{
                  name: "D",
              children: [
                %Pair{
                  k: "E",
                  v: "3"
                },
                %Pair{
                  k: "F",
                  v: "4"
                }
              ]
            }
          ]
        }

      fmt =
        @module.act ast

      assert match? ^fmt,
        """
        [A]
        B = 1
        C = 2

        [D]
        E = 3
        F = 4
        """
    end
  end

  describe "Will format a pair" do
    test "Will format a pair." do
      ast =
        %Env{
          state: [
            %Pair{
              k: "A",
              v: "1"
            }
          ]
        }

      fmt =
        @module.act ast

      assert match? ^fmt,
        """
        A = 1
        """
    end

    test "Will format more than one pair." do
      ast =
        %Env{
          state: [
            %Pair{
              k: "A",
              v: "1"
            },
            %Pair{
              k: "B",
              v: "2"
            }
          ]
        }

      fmt =
        @module.act ast

      assert match? ^fmt,
        """
        A = 1
        B = 2
        """
    end

    test "Will format a pair with no value." do
      ast =
        %Env{
          state: [
            %Pair{
              k: "A",
              v: ""
            }
          ]
        }

      fmt =
        @module.act ast

      assert match? ^fmt,
        """
        A
        """
    end

    test "Will format more than one pair with no value." do
      ast =
        %Env{
          state: [
            %Pair{
              k: "A",
              v: ""
            },
            %Pair{
              k: "B",
              v: ""
            }
          ]
        }

      fmt =
        @module.act ast

      assert match? ^fmt,
        """
        A
        B
        """
    end

    test "Will format a pair with subsequent newlines." do
      ast =
        %Env{
          state: [
            %Pair{
              k: "A",
              v: "1\n2\n3"
            }
          ]
        }

      fmt =
        @module.act ast

      assert match? ^fmt,
        """
        A = 1 \\
        2 \\
        3
        """
    end

    test "Will format a pair with unambigious UTF8 characters." do
      # TODO:
      #   Implement support for pretty formatting UTF8 characters.
      ast =
          %Env{
            state: [
              %Pair{
                k: "A",
                v: "1"
              },
              %Pair{
                k: <<209>>,
                v: "1"
              },
              %Pair{
                k: "2",
                v: <<212>>
              },
              %Pair{
                k: <<224>>,
                v: "3"
              }
            ]
          }

        fmt =
          @module.act ast

        assert match? ^fmt,
          """
          A = 1
          Ѭ = 1
          2 = Ԫ
          ࢉ = 3
          """
    end
  end
end
