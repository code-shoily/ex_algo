defmodule ExAlgo.List.AlgorithmTest do
  use ExUnit.Case
  use ExUnitProperties
  @moduletag :list_algorithms

  alias ExAlgo.List.Algorithms

  doctest ExAlgo.List.Algorithms

  property "Maximum subarray is equal to total of sum for all positive number arrays" do
    check all xs <- list_of(positive_integer()) do
      assert Algorithms.maximum_subarray_sum(xs) == Enum.sum(xs)
    end
  end

  property "Maximum subarray is larger than or equal to total of sum for mixed signed number arrays" do
    check all xs <- list_of(integer()) do
      assert Algorithms.maximum_subarray_sum(xs) >= Enum.sum(xs)
    end
  end

  property "Maximum subarray is equal to largest number in all negative number arrays" do
    check all xs <- nonempty(list_of(positive_integer())) do
      xs = Enum.map(xs, &(-1 * &1))
      assert Algorithms.maximum_subarray_sum(xs) == Enum.max(xs)
    end
  end
end
