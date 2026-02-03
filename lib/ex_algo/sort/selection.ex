defmodule ExAlgo.Sort.Selection do
  @moduledoc """
  Selection Sort

  ## Performance Warning

  This implementation has **O(n³) time complexity** instead of the expected O(n²)
  due to using the list subtraction operator (`--`) which is O(n) per deletion.

  Selection sort is designed for imperative languages where elements can be
  swapped in-place. In an immutable functional language like Elixir, "removing"
  an element requires scanning and rebuilding the list, making this algorithm
  fundamentally inefficient.

  **For production use, prefer `Merge.merge_sort/1` or `Enum.sort/1` instead.**

  This implementation is provided for educational purposes to demonstrate
  algorithms that don't translate well to functional programming.
  """
  @type item :: any()
  @type t :: [item()]

  @doc """
  Perform sort by using the selection_sort algorithm.

  ## Performance Warning

  This implementation is **O(n³)** due to the inefficiency of list operations
  in an immutable language. The `--` operator (line 33) must scan the entire
  list to remove each minimum element, resulting in O(n) × O(n²) = O(n³).

  **Not recommended for production use.** Use `Enum.sort/1` or `Merge.merge_sort/1` instead.

  ## Example

      iex> Selection.selection_sort([])
      []

      iex> Selection.selection_sort([1])
      [1]

      iex> Selection.selection_sort([3, 2, 1])
      [1, 2, 3]

      iex> Selection.selection_sort([2, 7, -1, 5])
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
