defmodule ExAlgo.List.BidirectionalListTest do
  use ExUnit.Case
  @moduletag :bidirectional_list

  alias ExAlgo.List.BidirectionalList

  doctest ExAlgo.List.BidirectionalList

  describe "inspect" do
    test "inspect an empty list" do
      assert inspect(BidirectionalList.new()) == "#ExAlgo.BidirectionalList<[]|[]>"
    end

    test "inspect an non-empty list" do
      assert inspect(BidirectionalList.from(1..5)) ==
               "#ExAlgo.BidirectionalList<[]|[1, 2, 3, 4, 5]>"
    end

    test "inspect an non-empty traversed list" do
      list = BidirectionalList.from(1..3) |> BidirectionalList.next()
      assert inspect(list) == "#ExAlgo.BidirectionalList<[1]|[2, 3]>"

      list = list |> BidirectionalList.next()
      assert inspect(list) == "#ExAlgo.BidirectionalList<[2, 1]|[3]>"

      list = list |> BidirectionalList.next()
      assert inspect(list) == "#ExAlgo.BidirectionalList<[3, 2, 1]|[]>"
    end
  end

  describe "collectable" do
    test "convert a List into BidirectionalList" do
      list = for i <- 1..10, into: %BidirectionalList{}, do: i
      assert list.upcoming == 10..1 |> Enum.to_list()
    end
  end
end
