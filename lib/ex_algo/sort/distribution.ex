defmodule ExAlgo.Sort.Distribution do
  @moduledoc """
  Distribution Sort (Pigeonhole Sort)

  ## Performance Warning

  This implementation has **O(n × range) time complexity** instead of the
  expected O(n + range) due to using the list concatenation operator (`++`)
  which rebuilds the left-hand list on each append.

  Pigeonhole sort is designed for imperative languages with arrays where
  elements can be placed directly at computed indices in O(1) time. In an
  immutable functional language like Elixir, building the result list with
  `++` causes quadratic behavior in the range size.

  **This algorithm becomes extremely slow when the range is large** (e.g.,
  sorting [1, 10000] is 1000× slower than [1, 10]).

  **For production use, prefer `Merge.merge_sort/1` or `Enum.sort/1` instead.**

  This implementation is provided for educational purposes to demonstrate
  algorithms that don't translate well to functional programming.
  """
  @type item :: any()
  @type t :: [item()]

  @doc """
  Perform sort by using the pigeonhole_sort algorithm.

  ## Performance Warning

  This implementation is **O(n × range)** where range = max - min. The `++`
  operator (line 46) rebuilds the accumulator list each time, making this
  extremely inefficient when the range is large.

  **Not recommended for production use**, especially with large ranges.
  Use `Enum.sort/1` or `Merge.merge_sort/1` instead.

  ## Example

      iex> Distribution.pigeonhole_sort([])
      []

      iex> Distribution.pigeonhole_sort([1])
      [1]

      iex> Distribution.pigeonhole_sort([3, 2, 1])
      [1, 2, 3]

      iex> Distribution.pigeonhole_sort([2, 7, -1, 5])
      [-1, 2, 5, 7]

  """
  @spec pigeonhole_sort(t) :: t
  def pigeonhole_sort([]), do: []

  def pigeonhole_sort(xs) do
    {base, max} = Enum.min_max(xs)

    pigeonhole_sort(
      base,
      max - base,
      Enum.reduce(xs, %{}, &Map.update(&2, &1, 1, fn item -> item + 1 end))
    )
  end

  def pigeonhole_sort(base, size, pigeonhole) do
    Enum.reduce(0..size, [], fn x, acc ->
      case pigeonhole[value = base + x] do
        nil ->
          acc

        rep ->
          acc ++
            (Stream.iterate(value, &Function.identity/1)
             |> Enum.take(rep))
      end
    end)
  end
end
