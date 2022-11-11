defmodule ExAlgo.DynamicProgramming.SubsetSum do
  @moduledoc """
  Provides functions related to subsets that sum to given target.

  FIXME: Currently this algorithm assumes all numbers are positive
  """

  @type nums :: [non_neg_integer()]
  @type cache :: %{required({non_neg_integer(), non_neg_integer()}) => boolean()}

  @doc """
  Initializes the cache. All cells are `false` except `{0, x}` where `nums[0] == x`

  ## Example

    iex> SubsetSum.init_cache([1, 2, 3], 3)
    %{
      {0, 0} => false, {0, 1} => true, {0, 2} => false, {0, 3} => false,
      {1, 0} => false, {1, 1} => false, {1, 2} => false, {1, 3} => false,
      {2, 0} => false, {2, 1} => false, {2, 2} => false, {2, 3} => false,
    }

  """
  @spec init_cache(nums(), non_neg_integer()) :: cache()
  def init_cache([head | _] = lst, target) do
    Enum.reduce(0..(length(lst) - 1), %{}, fn row, acc ->
      Enum.reduce(0..target, acc, fn col, cells ->
        Map.put(
          cells,
          {row, col},
          row == 0 && head == col
        )
      end)
    end)
  end

  @doc """
  Builds cache where each {x, y} value depicts a subset exists from `1..x` of sorted
  `nums` where the sum of that subset is `y`.

  ## Example

    iex> SubsetSum.build_cache([1, 2, 3], 3)
    %{
      {0, 0} => false, {0, 1} => true, {0, 2} => false, {0, 3} => false, # [1] has subset that sums to 1
      {1, 0} => false, {1, 1} => true, {1, 2} => true, {1, 3} => true, # [1, 2] has subsets that sums to 1, 2, 3
      {2, 0} => false, {2, 1} => true, {2, 2} => true, {2, 3} => true, # [1, 2, 3] has subsets that sums to 1, 2, 3
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

    Enum.reduce(1..count, cache, fn row, cache ->
      num = Enum.at(nums, row)

      0..target
      |> Enum.reduce(cache, fn col, cache ->
        remaining = col - num

        cache =
          Map.merge(
            cache,
            %{{row, col} => cache[{row - 1, col}] || num == col}
          )

        case {cache[{row, col}], 0 <= remaining, remaining < target} do
          {false, true, true} ->
            Map.merge(
              cache,
              %{{row, col} => cache[{row - 1, remaining}]}
            )

          _ ->
            cache
        end
      end)
    end)
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
  def has_subset_sum([], _), do: false

  def has_subset_sum(nums, target) do
    build_cache(nums, target)[{length(nums) - 1, target}]
  end
end
