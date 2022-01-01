defmodule ExAlgo.Sort.DistributionTest do
  use ExUnit.Case
  use ExUnitProperties
  @moduletag :distribution_sort

  alias ExAlgo.Sort.Distribution

  doctest ExAlgo.Sort.Distribution

  describe "pigeonhole_sort/1" do
    property "pigeonhole_sort sorts properly" do
      check all list <- list_of(integer()) do
        assert Distribution.pigeonhole_sort(list) == Enum.sort(list)
      end
    end
  end
end
