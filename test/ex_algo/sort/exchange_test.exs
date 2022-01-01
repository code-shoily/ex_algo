defmodule ExAlgo.Sort.ExchangeTest do
  use ExUnit.Case
  use ExUnitProperties
  @moduletag :exchange_sorts

  alias ExAlgo.Sort.Exchange

  doctest ExAlgo.Sort.Exchange

  describe "quick_sort/1" do
    property "ensure quick_sort done by any list produces the same result as enum sort" do
      check all list <- list_of(integer()) do
        assert Exchange.quick_sort(list) == Enum.sort(list)
      end
    end
  end

  describe "bubble_sort/1" do
    property "ensure bubble_sort done by any list produces the same result as enum sort" do
      check all list <- list_of(integer()) do
        assert Exchange.bubble_sort(list) == Enum.sort(list)
      end
    end
  end
end
