defmodule ExAlgo.Sort.Exchange do
  @moduledoc """
  Implements sorting algorithms based on exchanges.
  """
  @type item :: any()
  @type t :: [item()]

  @doc """
  Perform sort by using the bubble_sort algorithm.

  ## Example

      iex> Exchange.bubble_sort([])
      []

      iex> Exchange.bubble_sort([1])
      [1]

      iex> Exchange.bubble_sort([3, 2, 1])
      [1, 2, 3]

      iex> Exchange.bubble_sort([2, 7, -1, 5])
      [-1, 2, 5, 7]

  """
  @spec bubble_sort(t) :: t
  def bubble_sort(list), do: list |> bubble(true, [])
  defp bubble([], true, acc), do: acc |> Enum.reverse()
  defp bubble([], false, acc), do: acc |> Enum.reverse() |> bubble(true, [])
  defp bubble([a, b | rest], _, acc) when a > b, do: [a | rest] |> bubble(false, [b | acc])
  defp bubble([a | rest], rev?, acc), do: rest |> bubble(rev?, [a | acc])

  @doc """
  Perform sort by using the quick_sort algorithm.

  ## Performance Note

  This implementation always chooses the first element as the pivot, which
  results in **O(n²) worst-case performance on already-sorted lists** (a
  common real-world case).

  For better average-case performance, consider using a random pivot or
  median-of-three pivot selection. However, for production use, `Enum.sort/1`
  or `Merge.merge_sort/1` provide more consistent O(n log n) performance.

  ## Example

      iex> Exchange.quick_sort([])
      []

      iex> Exchange.quick_sort([1])
      [1]

      iex> Exchange.quick_sort([3, 2, 1])
      [1, 2, 3]

      iex> Exchange.quick_sort([2, 7, -1, 5])
      [-1, 2, 5, 7]

  """
  @spec quick_sort(t) :: t
  def quick_sort([]), do: []

  def quick_sort([pivot | rest]) do
    left =
      rest
      |> Enum.filter(&(&1 < pivot))
      |> quick_sort()

    right =
      rest
      |> Enum.filter(&(&1 >= pivot))
      |> quick_sort()

    left ++ List.wrap(pivot) ++ right
  end
end
