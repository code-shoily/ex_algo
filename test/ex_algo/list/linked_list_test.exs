defmodule ExAlgo.List.LinkedListTest do
  use ExUnit.Case
  use ExUnitProperties
  @moduletag :linked_list

  doctest ExAlgo.List.LinkedList

  alias ExAlgo.List.LinkedList

  setup_all do
    {:ok,
     %{
       empty_list: LinkedList.new(),
       list: LinkedList.from(1..5)
     }}
  end

  describe "new/0" do
    test "creates an empty linked list" do
      assert %LinkedList{container: []} == LinkedList.new()
    end
  end

  describe "from/1" do
    property "The list that is passed in is the container of the created list" do
      check all list <- list_of(integer()) do
        %LinkedList{container: container} = LinkedList.from(list)
        assert container == list
      end
    end
  end

  describe "insert/2" do
    test "insert an element in an empty list", %{empty_list: list} do
      assert %LinkedList{container: [0]} == list |> LinkedList.insert(0)
    end

    test "insert an element at the head of a list", %{list: list} do
      %LinkedList{container: container} = list |> LinkedList.insert(0)
      assert container == Enum.to_list(0..5)
    end
  end

  describe "remove/1" do
    test "error when trying to remove from an empty list", %{empty_list: list} do
      assert {:error, :empty_list} == list |> LinkedList.remove()
    end

    test "remove the head of the list", %{list: list} do
      {value, %LinkedList{container: container}} = list |> LinkedList.remove()
      assert value == hd(list.container)
      assert container == tl(list.container)
    end
  end

  describe "head/1" do
    property "head always returns the head of the underlying list" do
      check all list <- nonempty(list_of(integer())) do
        linked_list = LinkedList.from(list)
        assert LinkedList.head(linked_list) == hd(list)
      end
    end
  end

  describe "tail/1" do
    property "tail always returns the tail of the underlying list" do
      check all list <- nonempty(list_of(integer())) do
        linked_list = LinkedList.from(list)
        assert LinkedList.tail(linked_list) == tl(list)
      end
    end
  end

  describe "at/2" do
    test "cannot index an empty list", %{empty_list: list} do
      assert {:error, :empty_list} == LinkedList.at(list, 0)
      assert {:error, :empty_list} == LinkedList.at(list, 1)
    end

    test "cannot use negative index", %{list: list} do
      assert {:error, :negative_index} == LinkedList.at(list, -1)
    end

    test "when querying an empty list with negative index empty error is returned", %{
      empty_list: list
    } do
      assert {:error, :empty_list} == LinkedList.at(list, -1)
    end
  end

  describe "inspect" do
    test "inspect an empty list", %{empty_list: list} do
      assert inspect(list) == "#ExAlgo.LinkedList<[]>"
    end

    test "inspect an non-empty list", %{list: list} do
      assert inspect(list) == "#ExAlgo.LinkedList<[1, 2, 3, 4, 5]>"
    end
  end

  describe "collectable" do
    test "convert a List into LinkedList" do
      list = for i <- 1..10, into: %LinkedList{}, do: i
      assert list.container == 1..10 |> Enum.to_list()
    end
  end

  describe "enumerable" do
    test "length of a list", lists do
      assert lists.empty_list |> Enum.empty?()
      assert Enum.count(lists.list) == 5
    end

    test "map over a list", %{list: list} do
      assert Enum.map(list, fn elem -> elem ** 2 end) == [1, 4, 9, 16, 25]
    end

    test "filter over a list", %{list: list} do
      assert Enum.filter(list, fn elem -> elem > 1 end) == [2, 3, 4, 5]
    end

    test "convert a list to a set", %{list: list} do
      assert Enum.into(list, %MapSet{}) == MapSet.new([1, 2, 3, 4, 5])
    end
  end
end
