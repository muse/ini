defmodule INI.AST do
  @moduledoc """
  INI AST as structures.
  """
  @type t :: Environment.t() | Section.t() | Pair.t()

  defmacro __using__(_) do
    quote do
      alias INI.{AST, AST.Environment, AST.Section, AST.Pair}
    end
  end

  @doc """
  Convert the `module` to a lowercase binary.
  """
  @spec readable(module) :: binary
  def readable(module) do
    [module, _] =
      module
      |> Module.split()
      |> Enum.reverse()

    :"#{String.downcase(module)}"
  end

  defmodule Environment do
    @moduledoc """
    The INI environment.
    """
    @type t :: %__MODULE__{
         state: [Pair.t()],
      sections: [Section.t()]
    }

    defstruct [
         state: [],
      sections: []
    ]
  end

  defmodule Section do
    @moduledoc """
    An INI section.

    [name]
    """
    @type t :: %__MODULE__{
          name: binary,
      children: [Pair.t()]
    }

    defstruct [
          name: "",
      children: []
    ]
  end

  defmodule Pair do
    @moduledoc """
    An INI KVP.

    k = v
    """
    @type t :: %__MODULE__{
       k: binary,
       v: binary
    }

    defstruct [
       k: "",
       v: ""
    ]
  end
end
