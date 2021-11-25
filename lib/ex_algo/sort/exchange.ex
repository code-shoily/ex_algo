defmodule ExAlgo.Sort.Exchange do
  @moduledoc """
  Implements sorting algorithms based on exchanges.
  """
  @type item :: any()
  @type t :: [item()]

  @doc """
  Perform sort by using the bubble_sort algorithm.

  ## Example

      iex> import ExAlgo.Sort.Exchange
      iex> bubble_sort([])
      []
      iex> bubble_sort([1])
      [1]
      iex> bubble_sort([3, 2, 1])
      [1, 2, 3]
      iex> bubble_sort([2, 7, -1, 5])
      [-1, 2, 5, 7]

  """
  def bubble_sort(list), do: list |> bubble(true, [])
  defp bubble([], true, acc), do: acc |> Enum.reverse()
  defp bubble([], false, acc), do: acc |> Enum.reverse() |> bubble(true, [])
  defp bubble([a, b | rest], _, acc) when a > b, do: [a | rest] |> bubble(false, [b | acc])
  defp bubble([a | rest], rev?, acc), do: rest |> bubble(rev?, [a | acc])

  @doc """
  Perform sort by using the merge_sort algorithm.

  ## Example

      iex> import ExAlgo.Sort.Exchange
      iex> quick_sort([])
      []
      iex> quick_sort([1])
      [1]
      iex> quick_sort([3, 2, 1])
      [1, 2, 3]
      iex> quick_sort([2, 7, -1, 5])
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
