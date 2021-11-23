defmodule ExAlgo.Sort.InsertionTest do
  use ExUnit.Case
  use ExUnitProperties
  @moduletag :insertion_sorts

  doctest ExAlgo.Sort.Insertion

  alias ExAlgo.Sort.Insertion

  describe "insertion_sort/1" do
    property "ensure insertion_sort done by any list produces the same result as enum sort" do
      check all list <- list_of(integer()) do
        assert Insertion.insertion_sort(list) == Enum.sort(list)
      end
    end
  end
end
