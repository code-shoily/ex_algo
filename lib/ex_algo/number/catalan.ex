defmodule ExAlgo.Number.Catalan do
  @moduledoc """
  Catalan numbers are a sequence of natural numbers that occurs in many interesting
  counting problems like counting the number of expressions containing n pairs
  of parentheses that are correctly matched, the number of possible Binary Search
  Trees with n keys, the number of full binary trees etc.

  Here we present multiple ways to get Catalan numbers.

  The first few Catalan numbers are: 1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862

  To see a list of Catalan numbers to aid in testing, visit:

  https://www.mymathtables.com/numbers/first-hundred-catalan-number-table.html
  """

  @doc """
  Recursive implementation of catalan number.

  NOTE: This is SLOW.

  ## Example

      iex> 0..10 |> Enum.map(&Catalan.nth_recur/1)
      [1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862, 16796]

  """
  @spec nth_recur(non_neg_integer()) :: non_neg_integer()
  def nth_recur(n) when n <= 1, do: 1
  def nth_recur(n) when n > 1, do: do_recur(n, 0, 0)

  defp do_recur(n, n, catalan), do: catalan

  defp do_recur(n, iter, catalan) do
    do_recur(
      n,
      iter + 1,
      catalan + nth_recur(iter) * nth_recur(n - iter - 1)
    )
  end

  @doc """
  DP based implementation of catalan numbers.

  ## Example

      iex> 0..10 |> Enum.map(&Catalan.nth_dp/1)
      [1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862, 16796]

      iex> Catalan.nth_dp(100)
      896_519_947_090_131_496_687_170_070_074_100_632_420_837_521_538_745_909_320

  """
  @spec nth_dp(non_neg_integer()) :: non_neg_integer()
  def nth_dp(n), do: n |> as_map() |> Map.get(n)

  @doc """
  Dynamic programming implementation of catalan numbers that returns a list of
  catalan numbers until `n`.

  ## Example

      iex> Catalan.as_map(10)
      %{
        0 => 1,
        1 => 1,
        2 => 2,
        3 => 5,
        4 => 14,
        5 => 42,
        6 => 132,
        7 => 429,
        8 => 1430,
        9 => 4862,
        10 => 16796
      }

  """
  @spec as_map(non_neg_integer()) :: map()
  def as_map(n) when n <= 1, do: %{n => 1}

  def as_map(n) when n > 1 do
    2..n
    |> Enum.flat_map(fn i -> Enum.map(0..(i - 1), &{i, &1}) end)
    |> Enum.reduce(init_catalans(n), fn {i, j}, acc ->
      %{acc | i => acc[i] + acc[j] * acc[i - j - 1]}
    end)
  end

  defp init_catalans(limit) do
    0..limit
    |> Enum.map(fn value -> {value, (value > 1 && 0) || 1} end)
    |> Map.new()
  end
end
