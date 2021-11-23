defmodule ExAlgo.Sort.Insertion do
  @moduledoc """
  Implements sorting algorithms based on insertion.
  """
  @type item :: any()
  @type t :: [item()]

  @doc """
  Perform sort by using the merge_sort algorithm.

  ## Example

      iex> import ExAlgo.Sort.Insertion
      iex> insertion_sort([])
      []
      iex> insertion_sort([1])
      [1]
      iex> insertion_sort([3, 2, 1])
      [1, 2, 3]
      iex> insertion_sort([2, 7, -1, 5])
      [-1, 2, 5, 7]

  """
  @spec insertion_sort(t) :: t
  def insertion_sort([]), do: []

  def insertion_sort([head | rest]) do
    rest
    |> insertion_sort()
    |> insert(head)
  end

  @spec insert(t, item) :: t
  defp insert([], item), do: [item]
  defp insert([head | tail], item) when head < item, do: [head | insert(tail, item)]
  defp insert(sorted_list, item), do: [item | sorted_list]
end
