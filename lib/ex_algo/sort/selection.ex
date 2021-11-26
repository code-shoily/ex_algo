defmodule ExAlgo.Sort.Selection do
  @moduledoc """
  Selection Sort
  """
  @type item :: any()
  @type t :: [item()]

  @doc """
  Perform sort by using the selection_sort algorithm.

  ## Example

      iex> import ExAlgo.Sort.Selection
      iex> selection_sort([])
      []
      iex> selection_sort([1])
      [1]
      iex> selection_sort([3, 2, 1])
      [1, 2, 3]
      iex> selection_sort([2, 7, -1, 5])
      [-1, 2, 5, 7]

  """
  @spec selection_sort(t) :: t
  def selection_sort(xs), do: selection_sort(xs, [])

  def selection_sort([], result), do: Enum.reverse(result)

  def selection_sort(xs, result) do
    min = Enum.min(xs)
    xs = xs -- [min]
    selection_sort(xs, [min | result])
  end
end
