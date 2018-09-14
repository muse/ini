defmodule INI do
  @moduledoc """
  INI.Collector   # Tokenize and format to AST.
  INI.Typecaster  # Typecast int, float, bool & str.
  INI             # Parse and format INI.
  """
  alias INI.{
    Collector,
    Typecaster
  }

  def parse(ini) do
    ini
    |> Collector.act
    |> Typecaster.act
  end

  def format(ini) do
  end
end
