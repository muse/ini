defmodule INI do
  @moduledoc """
  """
  alias INI.{
    Collector,
    Typecaster,
    Formatter,
    AST
  }

  @doc """
  """
  @spec format(AST.t()) :: String.t()
  defdelegate format(ast), to: Formatter, as: :act

  @doc """
  """
  @spec typecast(AST.t()) :: AST.t()
  defdelegate typecast(ast), to: Typecaster, as: :act

  @doc """
  """
  @spec collect(String.t()) :: AST.t()
  defdelegate collect(ini), to: Collector, as: :act

  @doc """
  """
  @spec parse(String.t()) :: AST.t()
  def parse(ini) do
    ini
    |> Collector.act()
    |> Typecaster.act()
  end
end
