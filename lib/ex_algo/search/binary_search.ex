defmodule ExAlgo.Search.BinarySearch do
  @moduledoc """
  Implements a binary tree.

  Note: This is not an O(lg n) algorithm since it is based on List and random
  access on linked lists are of O(n). In a future iteration, it will be replaced
  with :array which also is not O(1) random access.

  TODO Implement Array version.
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
  @spec search(list[value()], value()) :: search_result()
  def search(haystack, needle), do: do_search(haystack, needle, 0, length(haystack))

  def do_search(_, _, start, stop) when start > stop, do: nil
  def do_search(haystack, needle, start, stop) do
    mid = (start + stop) |> div(2)
    case haystack |> Enum.at(mid) do
      ^needle -> mid
      value when value > needle -> haystack |> do_search(needle, start, mid - 1)
      value when value < needle -> haystack |> do_search(needle, mid + 1, stop)
    end
  end
end
