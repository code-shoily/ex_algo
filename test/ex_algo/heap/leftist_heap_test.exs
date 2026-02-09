defmodule ExAlgo.Heap.LeftistHeapTest do
  use ExUnit.Case
  @moduletag :heap

  alias ExAlgo.Heap.LeftistHeap
  alias ExAlgo.Heap.LeftistHeap.{Empty, Node}

  doctest ExAlgo.Heap.LeftistHeap

  describe "new/0" do
    test "creates an empty heap" do
      assert LeftistHeap.new() == %Empty{}
    end
  end

  describe "insert/2" do
    test "insert into empty heap" do
      heap = LeftistHeap.new() |> LeftistHeap.insert(5)
      assert %Node{value: 5, dist: 0, left: %Empty{}, right: %Empty{}} = heap
    end

    test "insert multiple elements maintains min heap property" do
      heap =
        LeftistHeap.new()
        |> LeftistHeap.insert(5)
        |> LeftistHeap.insert(3)
        |> LeftistHeap.insert(7)
        |> LeftistHeap.insert(1)

      assert {:ok, 1} = LeftistHeap.find_min(heap)
    end

    test "insert maintains leftist property" do
      heap =
        LeftistHeap.new()
        |> LeftistHeap.insert(10)
        |> LeftistHeap.insert(5)
        |> LeftistHeap.insert(15)
        |> LeftistHeap.insert(3)
        |> LeftistHeap.insert(8)

      # Verify leftist property: dist(left) >= dist(right) for all nodes
      assert leftist_property_holds?(heap)
    end
  end

  describe "find_min/1" do
    test "returns error for empty heap" do
      assert {:error, :empty} = LeftistHeap.new() |> LeftistHeap.find_min()
    end

    test "returns minimum element" do
      heap =
        LeftistHeap.new()
        |> LeftistHeap.insert(10)
        |> LeftistHeap.insert(5)
        |> LeftistHeap.insert(20)

      assert {:ok, 5} = LeftistHeap.find_min(heap)
    end

    test "minimum is always at root" do
      values = [15, 3, 8, 1, 20, 7, 12]
      heap = Enum.reduce(values, LeftistHeap.new(), &LeftistHeap.insert(&2, &1))
      assert {:ok, 1} = LeftistHeap.find_min(heap)
    end
  end

  describe "delete_min/1" do
    test "returns error for empty heap" do
      assert {:error, :empty} = LeftistHeap.new() |> LeftistHeap.delete_min()
    end

    test "deletes minimum from single element heap" do
      heap = LeftistHeap.new() |> LeftistHeap.insert(5)
      assert {:ok, %Empty{}} = LeftistHeap.delete_min(heap)
    end

    test "deletes minimum and maintains heap property" do
      heap =
        LeftistHeap.new()
        |> LeftistHeap.insert(5)
        |> LeftistHeap.insert(3)
        |> LeftistHeap.insert(7)
        |> LeftistHeap.insert(1)

      assert {:ok, heap2} = LeftistHeap.delete_min(heap)
      assert {:ok, 3} = LeftistHeap.find_min(heap2)
      assert LeftistHeap.count(heap2) == 3
    end

    test "repeated delete_min returns elements in sorted order" do
      values = [15, 3, 8, 1, 20, 7, 12]
      heap = Enum.reduce(values, LeftistHeap.new(), &LeftistHeap.insert(&2, &1))

      sorted = extract_all(heap)
      assert sorted == Enum.sort(values)
    end

    test "maintains leftist property after deletion" do
      heap =
        LeftistHeap.new()
        |> LeftistHeap.insert(1)
        |> LeftistHeap.insert(2)
        |> LeftistHeap.insert(3)
        |> LeftistHeap.insert(4)
        |> LeftistHeap.insert(5)

      {:ok, heap2} = LeftistHeap.delete_min(heap)
      assert leftist_property_holds?(heap2)
    end
  end

  describe "merge/2" do
    test "merge with empty heap returns other heap" do
      heap = LeftistHeap.new() |> LeftistHeap.insert(5)
      empty = LeftistHeap.new()

      assert LeftistHeap.merge(heap, empty) == heap
      assert LeftistHeap.merge(empty, heap) == heap
    end

    test "merge two empty heaps" do
      empty1 = LeftistHeap.new()
      empty2 = LeftistHeap.new()

      assert LeftistHeap.merge(empty1, empty2) == %Empty{}
    end

    test "merge two non-empty heaps maintains min heap property" do
      heap1 =
        LeftistHeap.new()
        |> LeftistHeap.insert(5)
        |> LeftistHeap.insert(10)
        |> LeftistHeap.insert(15)

      heap2 =
        LeftistHeap.new()
        |> LeftistHeap.insert(3)
        |> LeftistHeap.insert(8)
        |> LeftistHeap.insert(12)

      merged = LeftistHeap.merge(heap1, heap2)
      assert {:ok, 3} = LeftistHeap.find_min(merged)
      assert LeftistHeap.count(merged) == 6
    end

    test "merge maintains leftist property" do
      heap1 =
        LeftistHeap.new()
        |> LeftistHeap.insert(5)
        |> LeftistHeap.insert(10)
        |> LeftistHeap.insert(15)

      heap2 =
        LeftistHeap.new()
        |> LeftistHeap.insert(3)
        |> LeftistHeap.insert(8)
        |> LeftistHeap.insert(12)

      merged = LeftistHeap.merge(heap1, heap2)
      assert leftist_property_holds?(merged)
    end

    test "merge produces correct sorted order when extracting all elements" do
      heap1 = Enum.reduce([5, 10, 15], LeftistHeap.new(), &LeftistHeap.insert(&2, &1))
      heap2 = Enum.reduce([3, 8, 12], LeftistHeap.new(), &LeftistHeap.insert(&2, &1))

      merged = LeftistHeap.merge(heap1, heap2)
      sorted = extract_all(merged)
      assert sorted == [3, 5, 8, 10, 12, 15]
    end

    test "merge is commutative in terms of resulting heap content" do
      heap1 = Enum.reduce([5, 10, 15], LeftistHeap.new(), &LeftistHeap.insert(&2, &1))
      heap2 = Enum.reduce([3, 8, 12], LeftistHeap.new(), &LeftistHeap.insert(&2, &1))

      merged1 = LeftistHeap.merge(heap1, heap2)
      merged2 = LeftistHeap.merge(heap2, heap1)

      assert extract_all(merged1) == extract_all(merged2)
    end
  end

  describe "count/1" do
    test "empty heap has count 0" do
      assert LeftistHeap.count(LeftistHeap.new()) == 0
    end

    test "single element heap has count 1" do
      heap = LeftistHeap.new() |> LeftistHeap.insert(5)
      assert LeftistHeap.count(heap) == 1
    end

    test "count reflects number of elements" do
      heap =
        Enum.reduce(1..10, LeftistHeap.new(), fn i, acc ->
          LeftistHeap.insert(acc, i)
        end)

      assert LeftistHeap.count(heap) == 10
    end

    test "count decreases after delete_min" do
      heap =
        LeftistHeap.new()
        |> LeftistHeap.insert(1)
        |> LeftistHeap.insert(2)
        |> LeftistHeap.insert(3)

      assert LeftistHeap.count(heap) == 3
      {:ok, heap2} = LeftistHeap.delete_min(heap)
      assert LeftistHeap.count(heap2) == 2
    end
  end

  describe "heap sort property" do
    test "random elements are sorted correctly" do
      values = [23, 45, 12, 67, 8, 34, 90, 15, 3, 56]
      heap = Enum.reduce(values, LeftistHeap.new(), &LeftistHeap.insert(&2, &1))

      sorted = extract_all(heap)
      assert sorted == Enum.sort(values)
    end

    test "duplicate elements are handled correctly" do
      values = [5, 3, 5, 1, 3, 5, 1]
      heap = Enum.reduce(values, LeftistHeap.new(), &LeftistHeap.insert(&2, &1))

      sorted = extract_all(heap)
      assert sorted == Enum.sort(values)
    end

    test "already sorted elements" do
      values = 1..10 |> Enum.to_list()
      heap = Enum.reduce(values, LeftistHeap.new(), &LeftistHeap.insert(&2, &1))

      sorted = extract_all(heap)
      assert sorted == values
    end

    test "reverse sorted elements" do
      values = 10..1//-1 |> Enum.to_list()
      heap = Enum.reduce(values, LeftistHeap.new(), &LeftistHeap.insert(&2, &1))

      sorted = extract_all(heap)
      assert sorted == Enum.sort(values)
    end
  end

  describe "leftist property invariant" do
    test "large heap maintains leftist property" do
      heap = Enum.reduce(1..100, LeftistHeap.new(), &LeftistHeap.insert(&2, &1))
      assert leftist_property_holds?(heap)
    end

    test "leftist property holds after multiple operations" do
      heap =
        LeftistHeap.new()
        |> LeftistHeap.insert(50)
        |> LeftistHeap.insert(25)
        |> LeftistHeap.insert(75)
        |> LeftistHeap.insert(10)
        |> LeftistHeap.insert(30)

      {:ok, heap} = LeftistHeap.delete_min(heap)

      heap = LeftistHeap.insert(heap, 5)
      heap = LeftistHeap.insert(heap, 100)

      {:ok, heap} = LeftistHeap.delete_min(heap)

      assert leftist_property_holds?(heap)
    end
  end

  # Helper functions

  defp extract_all(%Empty{}), do: []

  defp extract_all(heap) do
    case LeftistHeap.delete_min(heap) do
      {:ok, %Empty{}} ->
        {:ok, min} = LeftistHeap.find_min(heap)
        [min]

      {:ok, rest} ->
        {:ok, min} = LeftistHeap.find_min(heap)
        [min | extract_all(rest)]

      {:error, :empty} ->
        []
    end
  end

  defp leftist_property_holds?(%Empty{}), do: true

  defp leftist_property_holds?(%Node{left: left, right: right}) do
    dist_left = dist(left)
    dist_right = dist(right)

    # Leftist property: dist(left) >= dist(right)
    dist_left >= dist_right and
      leftist_property_holds?(left) and
      leftist_property_holds?(right)
  end

  defp dist(%Empty{}), do: -1
  defp dist(%Node{dist: d}), do: d
end
