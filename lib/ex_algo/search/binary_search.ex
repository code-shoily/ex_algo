defmodule ExAlgo.Search.BinarySearch do
  @moduledoc """
  Implements a binary tree.

  ## Note on Complexity
    Standard Elixir Lists are linked lists, making random access an $O(N)$ operation.
    To achieve true $O(\\log N)$ search performance, this implementation converts the
    list to a **Tuple** first ($O(N)$).

    Once converted, `elem(tuple, index)` provides $O(1)$ access, allowing the
    divide-and-conquer logic to run in $O(\\log N)$ time.
  """
  @type value() :: any()
  @type search_result :: value() | nil

  @doc """
  Performs binary search on a sorted list.

  ## Example

      iex> [1, 2, 3, 4, 5] |> BinarySearch.search(1)
      0

      iex> [1, 2, 3, 4, 5] |> BinarySearch.search(5)
      4

      iex> [1, 2, 3, 4, 5] |> BinarySearch.search(2)
      1

      iex> [1, 2, 3, 4, 5] |> BinarySearch.search(4)
      3

      iex> [1, 2, 3, 4, 5] |> BinarySearch.search(-1)
      nil

  """
  @spec search(list(), any()) :: integer() | nil
  def search([], _), do: nil

  def search(list, needle) do
    # Convert to tuple once: O(n)
    haystack = List.to_tuple(list)
    do_search(haystack, needle, 0, tuple_size(haystack) - 1)
  end

  defp do_search(_haystack, _needle, start, stop) when start > stop, do: nil

  defp do_search(haystack, needle, start, stop) do
    mid = div(start + stop, 2)
    # O(1) access!
    val = elem(haystack, mid)

    cond do
      val == needle -> mid
      val > needle -> do_search(haystack, needle, start, mid - 1)
      val < needle -> do_search(haystack, needle, mid + 1, stop)
    end
  end
end
