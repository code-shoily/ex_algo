defmodule ExAlgo.Heap.PairingHeapTest do
  use ExUnit.Case
  @moduletag :heap

  alias ExAlgo.Heap.PairingHeap
  alias ExAlgo.Heap.PairingHeap.{Empty, Node}

  doctest ExAlgo.Heap.PairingHeap

  describe "new/0" do
    test "creates an empty heap" do
      assert PairingHeap.new() == %Empty{}
    end
  end

  describe "insert/2" do
    test "insert into empty heap" do
      heap = PairingHeap.new() |> PairingHeap.insert(5)
      assert %Node{value: 5, children: []} = heap
    end

    test "insert multiple elements maintains min heap property" do
      heap =
        PairingHeap.new()
        |> PairingHeap.insert(5)
        |> PairingHeap.insert(3)
        |> PairingHeap.insert(7)
        |> PairingHeap.insert(1)

      assert {:ok, 1} = PairingHeap.find_min(heap)
    end

    test "insert creates children in the multi-way tree" do
      heap =
        PairingHeap.new()
        |> PairingHeap.insert(10)
        |> PairingHeap.insert(5)
        |> PairingHeap.insert(15)

      assert %Node{value: 5, children: children} = heap
      assert Enum.count(children) == 2
    end
  end

  describe "find_min/1" do
    test "returns error for empty heap" do
      assert {:error, :empty} = PairingHeap.new() |> PairingHeap.find_min()
    end

    test "returns minimum element" do
      heap =
        PairingHeap.new()
        |> PairingHeap.insert(10)
        |> PairingHeap.insert(5)
        |> PairingHeap.insert(20)

      assert {:ok, 5} = PairingHeap.find_min(heap)
    end

    test "minimum is always at root" do
      values = [15, 3, 8, 1, 20, 7, 12]
      heap = Enum.reduce(values, PairingHeap.new(), &PairingHeap.insert(&2, &1))
      assert {:ok, 1} = PairingHeap.find_min(heap)
    end
  end

  describe "delete_min/1" do
    test "returns error for empty heap" do
      assert {:error, :empty} = PairingHeap.new() |> PairingHeap.delete_min()
    end

    test "deletes minimum from single element heap" do
      heap = PairingHeap.new() |> PairingHeap.insert(5)
      assert {:ok, %Empty{}} = PairingHeap.delete_min(heap)
    end

    test "deletes minimum and maintains heap property" do
      heap =
        PairingHeap.new()
        |> PairingHeap.insert(5)
        |> PairingHeap.insert(3)
        |> PairingHeap.insert(7)
        |> PairingHeap.insert(1)

      assert {:ok, heap2} = PairingHeap.delete_min(heap)
      assert {:ok, 3} = PairingHeap.find_min(heap2)
      assert PairingHeap.count(heap2) == 3
    end

    test "repeated delete_min returns elements in sorted order" do
      values = [15, 3, 8, 1, 20, 7, 12]
      heap = Enum.reduce(values, PairingHeap.new(), &PairingHeap.insert(&2, &1))

      sorted = extract_all(heap)
      assert sorted == Enum.sort(values)
    end

    test "delete_min performs two-pass pairing correctly" do
      # Build a heap with multiple children
      heap =
        PairingHeap.new()
        |> PairingHeap.insert(1)
        |> PairingHeap.insert(2)
        |> PairingHeap.insert(3)
        |> PairingHeap.insert(4)
        |> PairingHeap.insert(5)

      {:ok, heap2} = PairingHeap.delete_min(heap)
      assert {:ok, 2} = PairingHeap.find_min(heap2)
      assert PairingHeap.count(heap2) == 4
    end
  end

  describe "merge/2" do
    test "merge with empty heap returns other heap" do
      heap = PairingHeap.new() |> PairingHeap.insert(5)
      empty = PairingHeap.new()

      assert PairingHeap.merge(heap, empty) == heap
      assert PairingHeap.merge(empty, heap) == heap
    end

    test "merge two empty heaps" do
      empty1 = PairingHeap.new()
      empty2 = PairingHeap.new()

      assert PairingHeap.merge(empty1, empty2) == %Empty{}
    end

    test "merge two non-empty heaps maintains min heap property" do
      heap1 =
        PairingHeap.new()
        |> PairingHeap.insert(5)
        |> PairingHeap.insert(10)
        |> PairingHeap.insert(15)

      heap2 =
        PairingHeap.new()
        |> PairingHeap.insert(3)
        |> PairingHeap.insert(8)
        |> PairingHeap.insert(12)

      merged = PairingHeap.merge(heap1, heap2)
      assert {:ok, 3} = PairingHeap.find_min(merged)
      assert PairingHeap.count(merged) == 6
    end

    test "merge adds larger heap as child of smaller" do
      heap1 = PairingHeap.new() |> PairingHeap.insert(5)
      heap2 = PairingHeap.new() |> PairingHeap.insert(10)

      merged = PairingHeap.merge(heap1, heap2)
      assert %Node{value: 5, children: [%Node{value: 10}]} = merged
    end

    test "merge produces correct sorted order when extracting all elements" do
      heap1 = Enum.reduce([5, 10, 15], PairingHeap.new(), &PairingHeap.insert(&2, &1))
      heap2 = Enum.reduce([3, 8, 12], PairingHeap.new(), &PairingHeap.insert(&2, &1))

      merged = PairingHeap.merge(heap1, heap2)
      sorted = extract_all(merged)
      assert sorted == [3, 5, 8, 10, 12, 15]
    end

    test "merge is commutative in terms of resulting heap content" do
      heap1 = Enum.reduce([5, 10, 15], PairingHeap.new(), &PairingHeap.insert(&2, &1))
      heap2 = Enum.reduce([3, 8, 12], PairingHeap.new(), &PairingHeap.insert(&2, &1))

      merged1 = PairingHeap.merge(heap1, heap2)
      merged2 = PairingHeap.merge(heap2, heap1)

      assert extract_all(merged1) == extract_all(merged2)
    end
  end

  describe "count/1" do
    test "empty heap has count 0" do
      assert PairingHeap.count(PairingHeap.new()) == 0
    end

    test "single element heap has count 1" do
      heap = PairingHeap.new() |> PairingHeap.insert(5)
      assert PairingHeap.count(heap) == 1
    end

    test "count reflects number of elements" do
      heap =
        Enum.reduce(1..10, PairingHeap.new(), fn i, acc ->
          PairingHeap.insert(acc, i)
        end)

      assert PairingHeap.count(heap) == 10
    end

    test "count decreases after delete_min" do
      heap =
        PairingHeap.new()
        |> PairingHeap.insert(1)
        |> PairingHeap.insert(2)
        |> PairingHeap.insert(3)

      assert PairingHeap.count(heap) == 3
      {:ok, heap2} = PairingHeap.delete_min(heap)
      assert PairingHeap.count(heap2) == 2
    end
  end

  describe "heap sort property" do
    test "random elements are sorted correctly" do
      values = [23, 45, 12, 67, 8, 34, 90, 15, 3, 56]
      heap = Enum.reduce(values, PairingHeap.new(), &PairingHeap.insert(&2, &1))

      sorted = extract_all(heap)
      assert sorted == Enum.sort(values)
    end

    test "duplicate elements are handled correctly" do
      values = [5, 3, 5, 1, 3, 5, 1]
      heap = Enum.reduce(values, PairingHeap.new(), &PairingHeap.insert(&2, &1))

      sorted = extract_all(heap)
      assert sorted == Enum.sort(values)
    end

    test "already sorted elements" do
      values = 1..10 |> Enum.to_list()
      heap = Enum.reduce(values, PairingHeap.new(), &PairingHeap.insert(&2, &1))

      sorted = extract_all(heap)
      assert sorted == values
    end

    test "reverse sorted elements" do
      values = 10..1//-1 |> Enum.to_list()
      heap = Enum.reduce(values, PairingHeap.new(), &PairingHeap.insert(&2, &1))

      sorted = extract_all(heap)
      assert sorted == Enum.sort(values)
    end
  end

  describe "pairing heap specific operations" do
    test "two-pass pairing combines children correctly" do
      # Create a heap with many children at root level
      heap =
        Enum.reduce(1..7, PairingHeap.new(), fn i, acc ->
          PairingHeap.insert(acc, i)
        end)

      # Delete min should trigger two-pass pairing
      {:ok, heap2} = PairingHeap.delete_min(heap)

      # Verify heap property is maintained
      sorted = extract_all(heap2)
      assert sorted == [2, 3, 4, 5, 6, 7]
    end

    test "handles odd number of children in pairing" do
      # Build heap that will have odd number of children
      heap =
        PairingHeap.new()
        |> PairingHeap.insert(1)
        |> PairingHeap.insert(2)
        |> PairingHeap.insert(3)
        |> PairingHeap.insert(4)
        |> PairingHeap.insert(5)
        |> PairingHeap.insert(6)

      {:ok, heap2} = PairingHeap.delete_min(heap)
      assert PairingHeap.count(heap2) == 5
      assert {:ok, 2} = PairingHeap.find_min(heap2)
    end

    test "handles even number of children in pairing" do
      # Build heap that will have even number of children
      heap =
        PairingHeap.new()
        |> PairingHeap.insert(1)
        |> PairingHeap.insert(2)
        |> PairingHeap.insert(3)
        |> PairingHeap.insert(4)
        |> PairingHeap.insert(5)

      {:ok, heap2} = PairingHeap.delete_min(heap)
      assert PairingHeap.count(heap2) == 4
      assert {:ok, 2} = PairingHeap.find_min(heap2)
    end
  end

  describe "multi-way tree structure" do
    test "root can have many children" do
      heap =
        PairingHeap.new()
        |> PairingHeap.insert(1)
        |> PairingHeap.insert(5)
        |> PairingHeap.insert(3)
        |> PairingHeap.insert(7)
        |> PairingHeap.insert(2)

      assert %Node{value: 1, children: children} = heap
      refute Enum.empty?(children)
    end

    test "merge and delete operations maintain tree structure" do
      heap1 = Enum.reduce([10, 20, 30], PairingHeap.new(), &PairingHeap.insert(&2, &1))
      heap2 = Enum.reduce([5, 15, 25], PairingHeap.new(), &PairingHeap.insert(&2, &1))

      merged = PairingHeap.merge(heap1, heap2)
      {:ok, after_delete} = PairingHeap.delete_min(merged)

      # Should still have valid heap
      assert {:ok, _min} = PairingHeap.find_min(after_delete)
      assert PairingHeap.count(after_delete) == 5
    end
  end

  describe "stress tests" do
    test "large heap maintains heap property" do
      heap = Enum.reduce(1..100, PairingHeap.new(), &PairingHeap.insert(&2, &1))
      assert {:ok, 1} = PairingHeap.find_min(heap)
      assert PairingHeap.count(heap) == 100
    end

    test "many operations maintain correctness" do
      values = Enum.shuffle(1..50)
      heap = Enum.reduce(values, PairingHeap.new(), &PairingHeap.insert(&2, &1))

      # Delete first 25 elements
      heap =
        Enum.reduce(1..25, heap, fn _i, acc ->
          {:ok, new_heap} = PairingHeap.delete_min(acc)
          new_heap
        end)

      assert PairingHeap.count(heap) == 25
      assert {:ok, 26} = PairingHeap.find_min(heap)
    end

    test "merge many heaps maintains correctness" do
      heaps =
        1..10
        |> Enum.map(fn i ->
          start = (i - 1) * 10 + 1
          values = start..(start + 9)
          Enum.reduce(values, PairingHeap.new(), &PairingHeap.insert(&2, &1))
        end)

      merged = Enum.reduce(heaps, PairingHeap.new(), &PairingHeap.merge(&2, &1))

      assert PairingHeap.count(merged) == 100
      assert {:ok, 1} = PairingHeap.find_min(merged)

      sorted = extract_all(merged)
      assert sorted == Enum.to_list(1..100)
    end
  end

  # Helper functions

  defp extract_all(%Empty{}), do: []

  defp extract_all(heap) do
    case PairingHeap.delete_min(heap) do
      {:ok, %Empty{}} ->
        {:ok, min} = PairingHeap.find_min(heap)
        [min]

      {:ok, rest} ->
        {:ok, min} = PairingHeap.find_min(heap)
        [min | extract_all(rest)]

      {:error, :empty} ->
        []
    end
  end
end
