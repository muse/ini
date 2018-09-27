defmodule INI.Formatter do
  @moduledoc """
  TODO: Write.
  """
  use INI.AST

  def act(ast) do
    formatter(ast)
  end

  defp formatter(%Env{state: state, sections: sections} = env) do
    format(env)
      <> formatter(state)
      <> formatter(sections)
  end

  defp formatter([%Section{} | _] = sections) do
    sections
    |> Enum.map(&format/1)
    |> Enum.join("\n")
  end
  defp formatter([%Pair{} | _] = state) do
    state
    |> Enum.map(&format/1)
    |> Enum.join()
  end
  defp formatter([]) do
    <<>>
  end

  defp format(%Env{}) do
    """
    """
  end

  defp format(%Section{name: name, children: children}) do
    """
    [#{name}]
    """
    <> formatter(children)
  end

  defp format(%Pair{k: k, v: ""}) do
    """
    #{k}
    """
  end
  defp format(%Pair{k: k, v: v}) do
    """
    #{k} = #{String.replace(v, "\n", " \\\n")}
    """
  end
end
