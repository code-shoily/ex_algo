defmodule ExAlgo.Sort.SelectionTest do
  use ExUnit.Case
  use ExUnitProperties
  @moduletag :selection_sort

  doctest ExAlgo.Sort.Selection

  alias ExAlgo.Sort.Selection

  describe "selection_sort/1" do
    property "selection_sort sorts properly" do
      check all list <- list_of(integer()) do
        assert Selection.selection_sort(list) == Enum.sort(list)
      end
    end
  end
end
