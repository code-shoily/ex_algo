defmodule ExAlgo.Number.Catalan do
  @moduledoc """
  Catalan numbers are a sequence of natural numbers that occurs in many interesting
  counting problems like counting the number of expressions containing n pairs
  of parentheses that are correctly matched, the number of possible Binary Search
  Trees with n keys, the number of full binary trees etc.

  Here we present multiple ways to get Catalan numbers.

  The first few Catalan numbers are: 1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862
  """

  @doc """
  Recursive implementation of catalan number.

  NOTE: This is SLOW.

  ## Example

      iex> 0..10 |> Enum.map(&Catalan.recursive/1)
      [1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862, 16796]

  """
  def recursive(n) when n <= 1, do: 1
  def recursive(n), do: do_recursion(n, 0, 0)

  defp do_recursion(n, n, catalan), do: catalan
  defp do_recursion(n, iter, catalan) do
    do_recursion(
      n, iter + 1, catalan + recursive(iter) * recursive(n - iter - 1))
  end
end
