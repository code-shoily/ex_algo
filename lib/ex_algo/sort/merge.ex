defmodule ExAlgo.Sort.Merge do
  @moduledoc """
  Implements sorting algorithms based on exchanges.
  """
  @type item :: any()
  @type t :: [item()]

  @doc """
  Perform sort by using the merge_sort algorithm.

  ## Example

      iex> import ExAlgo.Sort.Merge
      iex> merge_sort([])
      []
      iex> merge_sort([1])
      [1]
      iex> merge_sort([3, 2, 1])
      [1, 2, 3]
      iex> merge_sort([2, 7, -1, 5])
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
    |> then(fn {left, right} -> merge(left, right) end)
  end

  @spec merge(t, t) :: t
  defp merge([], right), do: right
  defp merge(left, []), do: left
  defp merge([x | xs], [y | _] = right) when x < y, do: [x | merge(xs, right)]
  defp merge(left, [y | ys] ), do: [y | merge(ys, left)]
end
