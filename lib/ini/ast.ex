defmodule INI.AST do
  @moduledoc """
  INI AST as structures.
  """
  @type t :: Env.t() | Section.t() | Pair.t()

  defmacro __using__(_) do
    quote do
      alias INI.{AST, AST.Env, AST.Section, AST.Pair}
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

    Macro.underscore(module)
  end

  defmodule Env do
    @moduledoc """
    The INI env.
    """
    @type t :: %__MODULE__{
      sections: [Section.t()],
         state: [Pair.t()]
    }

    defstruct [
      sections: [],
         state: []
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
