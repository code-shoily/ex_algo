defmodule ExAlgo.Counting.Combinatorics do
  @moduledoc """
  Combinatorics functions.
  """

  @doc """
  Computes the permutations of a list.

  ## Example

      iex> Combinatorics.permutations([])
      [[]]

      iex> Combinatorics.permutations([1, 2])
      [[1, 2], [2, 1]]

      iex> Combinatorics.permutations([1, 2, 3])
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]

  """
  def permutations([]) do
    [[]]
  end

  def permutations(list) do
    for h <- list, t <- permutations(list -- [h]), do: [h | t]
  end

  @doc """
  Computes the nCr of a list.

  ## Examples

      iex> Combinatorics.combinations([1, 2, 3], 0)
      [[]]

      iex> Combinatorics.combinations([], 100)
      []

      iex> Combinatorics.combinations([], 0)
      [[]]

      iex> Combinatorics.combinations([1, 2, 3], 2)
      [[1, 2], [1, 3], [2, 3]]

      iex> Combinatorics.combinations([1, 2, 3, 4], 3)
      [[1, 2, 3], [1, 2, 4], [1, 3, 4], [2, 3, 4]]

      iex> Combinatorics.combinations([1, 2, 3, 4, 5], 5)
      [[1, 2, 3, 4, 5]]

      iex> Combinatorics.combinations([1, 2, 3, 4, 5], 1)
      [[1], [2], [3], [4], [5]]

  """
  def combinations(_, 0), do: [[]]
  def combinations([], _), do: []

  def combinations([x | xs], r) do
    for(y <- combinations(xs, r - 1), do: [x | y]) ++ combinations(xs, r)
  end
end
