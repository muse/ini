defmodule INI.Typecaster do
  @moduledoc """
  """
  use INI.AST

  @spec act(Environment.t()) :: Environment.t()
  def act(%Environment{sections: sections, state: state} = environment) do
    %{environment | sections: typecaster(sections), state: typecaster(state)}
  end

  @spec typecasters :: [(Pair.t() -> {:ok, any} | :error)]
  defp typecasters do
    [&number/1, &boolean/1, &binary/1]
  end

  @spec typecaster([Section.t() | Pair.t()] | []) :: [Section.t() | Pair.t()] | []
  defp typecaster([%Section{} | _] = sections) do
    Enum.map(sections, fn %{children: children} = section ->
      %{section | children: typecaster(children)}
    end)
 end
  defp typecaster([%Pair{} | _] = state) do
    Enum.map(state, fn pair ->
      {:ok, v} =
        Enum.reduce(typecasters(), :error, fn
          _, {:ok, _} = accumulator ->
            accumulator

          caster, :error ->
            caster.(pair)
        end)

      %{pair | v: v}
    end)
  end
  defp typecaster([]) do
    []
  end

  @spec number(Pair.t()) :: {:ok, integer | float} | :error
  defp number(%Pair{v: v}) do
    parser =
      String.contains?(v, ".") && Float || Integer

    with {number, _} <- parser.parse(v) do
      {:ok, number}
    end
  end

  @spec boolean(Pair.t()) :: {:ok, true | false} | :error
  defp boolean(%Pair{v: "true"}) do
    {:ok, true}
  end

  defp boolean(%Pair{v: "false"}) do
    {:ok, false}
  end

  defp boolean(%Pair{}) do
    :error
  end

  @spec binary(Pair.t()) :: {:ok, binary}
  defp binary(%Pair{v: <<?", _::binary>> = v}) do
    {:ok, String.trim(v, "\"")}
  end

  defp binary(%Pair{v: v}) do
    {:ok, v}
  end
end
