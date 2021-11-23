defmodule ExAlgo.Sort.Exchange do
  @moduledoc """
  Implements sorting algorithms based on exchanges.
  """
  @type item :: any()
  @type t :: [item()]

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
