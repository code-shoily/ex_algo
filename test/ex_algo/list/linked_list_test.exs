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
       list: LinkedList.from(1..10)
     }}
  end

  describe "new/0" do
    test "creates an empty linked list" do
      assert %LinkedList{container: []} == LinkedList.new()
    end
  end

  describe "from/1" do
    property "The list that is passed in is the container of the created list" do
      check all list <- list_of(term()) do
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
      assert container == Enum.to_list(0..10)
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
      check all list <- nonempty(list_of(term())) do
        linked_list = LinkedList.from(list)
        assert LinkedList.head(linked_list) == hd(list)
      end
    end
  end

  describe "tail/1" do
    property "tail always returns the tail of the underlying list" do
      check all list <- nonempty(list_of(term())) do
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
end
