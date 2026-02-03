defmodule ExAlgo.DynamicProgramming.SubsetSum do
  @moduledoc """
  Provides functions for the subset sum problem using dynamic programming.

  ## Limitation

  This implementation is optimized for non-negative integers only. The algorithm
  uses a DP table indexed by sum values, which assumes non-negative sums.

  For arrays containing negative numbers, a different approach is needed that
  handles negative intermediate sums. Consider implementing a separate module
  (e.g., `SubsetSumGeneral`) if negative number support is required.

  ## Algorithm

  Uses dynamic programming with a 2D cache where `cache[{i, j}]` represents
  whether a subset of the first `i+1` elements can sum to `j`.

  Time complexity: O(n * target) where n is the number of elements
  Space complexity: O(n * target)
  """

  @type nums :: [non_neg_integer()]
  @type cache :: %{required({non_neg_integer(), non_neg_integer()}) => boolean()}

  @doc """
  Initializes the cache. Column 0 (target=0) is always `true` (empty subset),
  and `{0, x}` is `true` where `nums[0] == x`

  ## Example

    iex> SubsetSum.init_cache([1, 2, 3], 3)
    %{
      {0, 0} => true, {0, 1} => true, {0, 2} => false, {0, 3} => false,
      {1, 0} => true, {1, 1} => false, {1, 2} => false, {1, 3} => false,
      {2, 0} => true, {2, 1} => false, {2, 2} => false, {2, 3} => false,
    }

  """
  @spec init_cache(nums(), non_neg_integer()) :: cache()
  def init_cache([head | _] = lst, target) do
    num_rows = length(lst)

    for row <- 0..(num_rows - 1),
        col <- 0..target//1,
        into: %{} do
      {{row, col}, col == 0 || (row == 0 && head == col)}
    end
  end

  @doc """
  Builds cache where each {x, y} value depicts a subset exists from `0..x` of sorted
  `nums` where the sum of that subset is `y`.

  ## Example

    iex> SubsetSum.build_cache([1, 2, 3], 3)
    %{
      {0, 0} => true, {0, 1} => true, {0, 2} => false, {0, 3} => false, # [] or [1] can make 0 or 1
      {1, 0} => true, {1, 1} => true, {1, 2} => true, {1, 3} => true, # [1, 2] can make 0, 1, 2, 3
      {2, 0} => true, {2, 1} => true, {2, 2} => true, {2, 3} => true, # [1, 2, 3] can make 0, 1, 2, 3
    }

  """
  @spec build_cache(nums(), non_neg_integer()) :: cache()
  def build_cache(nums, target) do
    nums = Enum.sort(nums)
    cache = init_cache(nums, target)
    build_cache(nums, cache, target)
  end

  def build_cache(nums, cache, target) do
    count = length(nums) - 1

    Enum.reduce(1..count//1, cache, fn row, cache ->
      num = Enum.at(nums, row)
      Enum.reduce(0..target//1, cache, &update_cache_cell(&1, &2, row, num))
    end)
  end

  defp update_cache_cell(col, cache, row, num) do
    cache = Map.put(cache, {row, col}, cache[{row - 1, col}] || num == col)
    maybe_update_from_remaining(cache, row, col, num)
  end

  defp maybe_update_from_remaining(cache, row, col, num) do
    remaining = col - num

    if !cache[{row, col}] && remaining >= 0 && remaining < col do
      Map.put(cache, {row, col}, cache[{row - 1, remaining}])
    else
      cache
    end
  end

  @doc """
  Determines if there exists a subset in a list that sums to the given target.

  Reference: https://www.geeksforgeeks.org/subset-sum-problem-dp-25/

  ## Example

    iex> SubsetSum.has_subset_sum([1, 2, 3], 3)
    true

    iex> SubsetSum.has_subset_sum([1, 3, 7], 2)
    false

    iex> SubsetSum.has_subset_sum([], 10)
    false

    iex> SubsetSum.has_subset_sum([1, 2, 3], -1)
    false

    iex> SubsetSum.has_subset_sum([1, 2, 3, 4], 11)
    false

  """
  @spec has_subset_sum(nums(), non_neg_integer()) :: boolean()
  def has_subset_sum([], 0), do: true
  def has_subset_sum([], _), do: false
  def has_subset_sum(_, 0), do: true
  def has_subset_sum(_, target) when target < 0, do: false

  def has_subset_sum(nums, target) do
    has_subset_sum(nums, target, build_cache(nums, target))
  end

  def has_subset_sum(nums, target, cache) when is_map(cache) do
    cache[{length(nums) - 1, target}]
  end

  @doc """
  Returns a list of subsets that sum to the target.

  ## Limitation

  This implementation may not find all possible subsets that sum to the target.
  It was designed to solve a specific problem and may return only a subset of
  valid solutions.

  For a complete enumeration of all valid subsets, a different backtracking
  approach would be needed.
  """
  def find_subsets(nums, target) do
    cache = build_cache(nums, target)
    nums = Enum.sort(nums)
    nums_map = as_map(nums)

    if has_subset_sum(nums, target, cache) do
      n = length(nums) - 1
      stack = [{n, target, [n], target - nums_map[n]}]
      do_find_subsets(nums_map, target, cache, stack, [])
    end
  end

  defp do_find_subsets(_, _, _, [], subsets), do: subsets

  defp do_find_subsets(nums, target, cache, [{_, _, take, 0} | stack], subsets) do
    subset = Map.values(Map.take(nums, take))
    do_find_subsets(nums, target, cache, stack, [subset | subsets])
  end

  defp do_find_subsets(nums, target, cache, [{i, j, take, togo} | stack], subsets) do
    stack =
      (cache[{i - 1, j}] &&
         [{i - 1, j, replace_last(take, i - 1), togo + nums[i] - nums[i - 1]} | stack]) || stack

    stack =
      (cache[{i - 1, j - nums[i]}] &&
         [{i - 1, j - nums[i], take ++ [i - 1], togo - nums[i - 1]} | stack]) || stack

    do_find_subsets(nums, target, cache, stack, subsets)
  end

  defp replace_last(lst, replacement) do
    lst
    |> Enum.reverse()
    |> then(fn [_ | rest] -> [replacement | rest] end)
    |> Enum.reverse()
  end

  defp as_map(nums) do
    nums
    |> Enum.with_index()
    |> Map.new(fn {a, b} ->
      {b, a}
    end)
  end
end
