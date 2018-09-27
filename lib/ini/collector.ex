defmodule INI.Collector do
  @moduledoc """
  ## Token stream preparation.

    * We receive a binary string containing (presumably) INI configuration.

        '''
        A=1
        B=2
        C=3
        '''

    * We split the binary on each character, trimming the residue.

        ["A", "=", "1", "\n", "B", "=", "2", "\n", "C", "=", "3", "\n"]

    * We chunk the characters together in pairs of two. Whenever an uneven
      amount of characters arises, a NULL byte is appended at the end to make up for
      it.

        [
          ["A", "="],
          ["=", "1"],
          ["1", "\n"],
          ["\n", "B"],
          ["B", "="],
          ["=", "2"],
          ["2", "\n"],
          ["\n", "C"],
          ["C", "="],
          ["=", "3"],
          ["3", "\n"],
          ["\n", <<0>>]
        ]

    * Finally, we concatenate the two characters back together, ending up with
      our token stream.

        [
          "A=",
          "=1",
          "1\n",
          "\nB",
          "B=",
          "=2",
          "2\n",
          "\nC",
          "C=",
          "=3",
          "3\n",
          <<10, 0>>
        ]

  # Collection precedence.

    Rewrite.

  """
  use INI.AST

  @type accumulator :: %{
    # The normal section stack and the state pair stack.
          stack: list,
          state: list,

    # The current section.
        section: nil
               | Section.t(),

    # The current pair.
           pair: nil
               | Pair.t(),

    # The active collector mode.
    #
    # :k         , We're collecting for a `Pair.t()` :k.
    # :v         , We're collecting for a `Pair.t()` :v.
    # :name      , We're collecting for a `Section.t()` :name.
    # {:skip, _} , We're not collecting anything right now, return to :_ after.
           mode: :k
               | :v
               | :name
               | {:skip, :k | :v}
  }

  @typedoc """
  A token is a size(2) binary.
  """
  @type token :: <<_::16>>

  @doc """
  Return the env and the section based AST stacks from the `stream`.
  """
  @spec act(String.t()) :: Env.t()
  def act(stream) do
    stream
    |> prepare()
    |> collector()
  end

  @doc """
  Return the `section` with their `children` reversed.
  """
  @spec reverse(Section.t()) :: Section.t()
  def reverse(%Section{children: children} = section) do
    %{section | children: Enum.reverse(children)}
  end

  @spec prepare(String.t()) :: [token]
  defp prepare(stream) do
    stream
    |> String.split(<<>>, trim: true)
    |> Enum.chunk_every(2, 1, [<<0>>])
    |> Enum.map(&Enum.join/1)
  end

  @spec trim(Pair.t()) :: Pair.t()
  defp trim(%Pair{k: k, v: v} = pair) do
    %{pair | k: String.trim(k), v: String.trim(v)}
  end

  @spec collector([token]) :: Env.t()
  defp collector(stream) do
    accumulator = %{
        stack: [],
        state: [],
      section: nil,
         pair: nil,
         mode: :k
    }

    %{section: section, stack: stack, state: state} =
      Enum.reduce(stream, accumulator, &collect/2)

    %Env{
      sections: Enum.reverse(section && [reverse(section) | stack] || stack),
         state: Enum.reverse(state)
    }
  end

  @spec collect(token, accumulator) :: accumulator
  defp collect(<<?\n, _::binary>>, %{mode: {:skip, previous}} = accumulator) do
    %{accumulator | mode: previous}
  end

  # TODO: Find out about the necessity of this clause.
  # defp collect(<<?\\, ?\n>>, %{mode: mode, pair: %Pair{}} = accumulator) do
  #   %{accumulator | mode: {:skip, mode}}
  # end

  defp collect(<<_, _::binary>>, %{mode: {:skip, _}} = accumulator) do
    accumulator
  end

  defp collect(<<?[, _::binary>>, %{section: %Section{} = section, stack: stack} = accumulator) do
    %{accumulator | mode: :name, stack: [reverse(section) | stack], section: %Section{}}
  end

  defp collect(<<?[, _::binary>>, %{section: nil} = accumulator) do
    %{accumulator | mode: :name, section: %Section{}}
  end

  defp collect(<<?], _::binary>>, %{mode: :name, section: %Section{}} = accumulator) do
    %{accumulator | mode: :k}
  end

  defp collect(<<?\n, _::binary>>, %{section: nil, pair: %Pair{} = pair, state: state} = accumulator) do
    %{accumulator | mode: :k, pair: nil, state: [trim(pair) | state]}
  end

  defp collect(<<?\n, _::binary>>, %{section: %Section{children: children} = section, pair: %Pair{} = pair} = accumulator) do
    %{accumulator | mode: :k, pair: nil, section: %{section | children: [trim(pair) | children]}}
  end

  defp collect(<<?\n, _::binary>>, %{pair: nil} = accumulator) do
    accumulator
  end

  defp collect(<<?=, _::binary>>, %{mode: :k} = accumulator) do
    %{accumulator | mode: :v}
  end

  defp collect(<<?;, _::binary>>, %{mode: mode, pair: nil} = accumulator) do
    %{accumulator | mode: {:skip, mode}}
  end

  defp collect(<<token, _::binary>>, %{mode: :name, section: %Section{name: name} = section} = accumulator) do
    %{accumulator | section: %{section | name: name <> <<token>>}}
  end

  defp collect(<<token, _::binary>>, %{mode: mode, pair: %Pair{} = pair} = accumulator) do
    %{accumulator | pair: %{pair | mode => Map.fetch!(pair, mode) <> <<token>>}}
  end

  defp collect(<<token, _::binary>>, %{pair: nil} = accumulator) do
    %{accumulator | pair: %{%Pair{} | k: <<token>>}}
  end

  # TODO: Find out about the necessity of this clause.
  # defp collect(<<"", _::binary>>, accumulator) do
  #   accumulator
  # end
end
