defmodule ExAlgo.List.Algorithms do
  @moduledoc """
  Various list focused algorithms.
  """

  @doc """
  Kadane's Algorithm for finding the maximum sub-array.

  ##Example

      iex> Algorithms.maximum_subarray_sum([])
      0

      iex> Algorithms.maximum_subarray_sum([1])
      1

      iex> Algorithms.maximum_subarray_sum([-2, 1, 3, 4, -1, 2, 1, -5, 4])
      10

  """
  @spec maximum_subarray_sum([number()]) :: number()
  def maximum_subarray_sum(xs), do: do_maximum_subarray_sum(xs, 0, nil)

  defp do_maximum_subarray_sum([], _local_max, global_max), do: global_max || 0

  defp do_maximum_subarray_sum([a | rest], local_max, global_max) do
    local_max = Enum.max([a, a + local_max])
    global_max = maximum(local_max, global_max)
    do_maximum_subarray_sum(rest, local_max, global_max)
  end

  defp maximum(a, nil), do: a
  defp maximum(a, b), do: (a < b && b) || a
end
