defmodule ExAlgo.List.CircularListTest do
  use ExUnit.Case
  use ExUnitProperties
  @moduletag :circular_list

  alias ExAlgo.List.CircularList

  doctest ExAlgo.List.CircularList

  describe "inspect" do
    test "inspect an empty list" do
      assert inspect(CircularList.new()) == "#ExAlgo.CircularList<[]|[]>"
    end

    test "inspect an non-empty list" do
      assert inspect(CircularList.from(1..5)) == "#ExAlgo.CircularList<[]|[1, 2, 3, 4, 5]>"
    end

    test "inspect an non-empty traversed list" do
      list = CircularList.from(1..3) |> CircularList.next()
      assert inspect(list) == "#ExAlgo.CircularList<[1]|[2, 3]>"

      list = list |> CircularList.next()
      assert inspect(list) == "#ExAlgo.CircularList<[2, 1]|[3]>"

      list = list |> CircularList.next()
      assert inspect(list) == "#ExAlgo.CircularList<[3, 2, 1]|[]>"
    end
  end

  describe "collectable" do
    test "convert a List into CircularList" do
      list = for i <- 1..10, into: %CircularList{}, do: i
      assert list.upcoming == 10..1//-1 |> Enum.to_list()
    end
  end

  describe "enumerable" do
    test "length of a list" do
      assert CircularList.new() |> Enum.empty?()
      assert CircularList.from(1..5) |> Enum.count() == 5
    end

    test "map over a list" do
      assert 1..4 |> CircularList.from() |> Enum.map(&(&1 ** 2)) == [1, 4, 9, 16]
    end

    test "filter over a list" do
      assert 1..5 |> CircularList.from() |> Enum.filter(&(&1 > 1)) == [2, 3, 4, 5]
    end

    test "convert a list to a set" do
      assert 1..5 |> CircularList.from() |> Enum.into(%MapSet{}) == MapSet.new([1, 2, 3, 4, 5])
    end
  end

  property "circular list to list will always return the list regardless of the visited or upcoming" do
    check all list <- nonempty(list_of(integer())),
              repeat <- integer(1..100) do
      as_list =
        1..repeat
        |> Enum.reduce(CircularList.from(list), fn _, acc ->
          CircularList.next(acc)
        end)
        |> CircularList.to_list()

      assert as_list == list
    end
  end

  property "when indexing for number, it will be the remainder between that number and length" do
    check all list <- nonempty(list_of(integer())),
              index <- integer(0..10_000) do
      circular_list = CircularList.from(list)
      assert CircularList.at(circular_list, index) == Enum.at(list, rem(index, length(list)))
    end
  end

  property "from copies a list into circular list, into inserts list one by one into circular list" do
    check all list <- nonempty(list_of(integer())) do
      list_1 = list |> CircularList.from() |> CircularList.to_list()
      list_2 = list |> Enum.into(%CircularList{}) |> CircularList.to_list()
      assert list_1 == Enum.reverse(list_2)
    end
  end
end
