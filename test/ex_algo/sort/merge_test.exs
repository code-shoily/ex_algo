defmodule ExAlgo.Sort.MergeTest do
  use ExUnit.Case
  use ExUnitProperties
  @moduletag :merge_sorts

  alias ExAlgo.Sort.Merge

  doctest ExAlgo.Sort.Merge

  describe "merge_sort/1" do
    property "ensure merge_sort done by any list produces the same result as enum sort" do
      check all list <- list_of(integer()) do
        assert Merge.merge_sort(list) == Enum.sort(list)
      end
    end
  end
end
