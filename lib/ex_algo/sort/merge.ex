defmodule ExAlgo.Sort.Merge do
  @moduledoc """
  Implements sorting algorithms based on exchanges.
  """
  @type item :: any()
  @type t :: [item()]

  @doc """
  Perform sort by using the merge_sort algorithm.

  ## Example

      iex> Merge.merge_sort([])
      []

      iex> Merge.merge_sort([1])
      [1]

      iex> Merge.merge_sort([3, 2, 1])
      [1, 2, 3]

      iex> Merge.merge_sort([2, 7, -1, 5])
      [-1, 2, 5, 7]

  """
  @spec merge_sort(t) :: t
  def merge_sort([]), do: []
  def merge_sort([_] = list), do: list

  def merge_sort(list) do
    half = list |> length() |> div(2)

    list
    |> Enum.split(half)
    |> then(fn {left, right} ->
      {merge_sort(left), merge_sort(right)}
    end)
    |> then(fn {left, right} -> do_merge(left, right, []) end)
  end

  defp do_merge([], right, acc), do: Enum.reverse(acc) ++ right
  defp do_merge(left, [], acc), do: Enum.reverse(acc) ++ left

  defp do_merge([x | xs], [y | _] = ys, acc) when x < y do
    # Tail call!
    do_merge(xs, ys, [x | acc])
  end

  defp do_merge(xs, [y | ys], acc) do
    # Tail call!
    do_merge(xs, ys, [y | acc])
  end
end
