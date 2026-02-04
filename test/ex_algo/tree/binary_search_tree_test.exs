defmodule ExAlgo.Tree.BinarySearchTreeTest do
  use ExUnit.Case
  use ExUnitProperties
  @moduletag :bst

  alias ExAlgo.Tree.BinarySearchTree, as: BST
  alias ExAlgo.Tree.Traversal

  doctest BST

  property "A list with a single element using `from` is the same as adding that as root" do
    check all value <- integer() do
      assert BST.new(value) == BST.from(List.wrap(value))
    end
  end

  property "Inorder traversal on a binary tree will produce sorted data" do
    check all list <- nonempty(list_of(integer())) do
      tree = BST.from(list)
      inorder_traversal = Traversal.inorder(tree)

      assert inorder_traversal == Enum.sort(list)
    end
  end

  describe "delete/2" do
    test "deleting from empty tree returns nil" do
      assert BST.delete(nil, 5) == nil
    end

    test "deleting a leaf node" do
      tree = BST.from([10, 5, 15, 3, 7, 12, 20])
      tree = BST.delete(tree, 3)

      assert Traversal.inorder(tree) == [5, 7, 10, 12, 15, 20]
    end

    test "deleting a node with only left child" do
      tree = BST.from([10, 5, 3])
      tree = BST.delete(tree, 5)

      assert Traversal.inorder(tree) == [3, 10]
    end

    test "deleting a node with only right child" do
      tree = BST.from([10, 5, 7])
      tree = BST.delete(tree, 5)

      assert Traversal.inorder(tree) == [7, 10]
    end

    test "deleting a node with two children" do
      tree = BST.from([10, 5, 15, 3, 7, 12, 20])
      tree = BST.delete(tree, 15)

      assert Traversal.inorder(tree) == [3, 5, 7, 10, 12, 20]
    end

    test "deleting the root node with two children" do
      tree = BST.from([10, 5, 15, 3, 7, 12, 20])
      tree = BST.delete(tree, 10)

      # Should be replaced by inorder successor (12)
      assert Traversal.inorder(tree) == [3, 5, 7, 12, 15, 20]
      assert tree.data == 12
    end

    test "deleting the root node with one child" do
      tree = BST.from([10, 5])
      tree = BST.delete(tree, 10)

      assert Traversal.inorder(tree) == [5]
      assert tree.data == 5
    end

    test "deleting the only node in tree" do
      tree = BST.new(10)
      tree = BST.delete(tree, 10)

      assert tree == nil
    end

    test "deleting non-existent value does not change tree" do
      tree = BST.from([10, 5, 15])
      tree_after = BST.delete(tree, 99)

      assert Traversal.inorder(tree) == Traversal.inorder(tree_after)
    end

    test "deleting all nodes one by one" do
      values = [10, 5, 15, 3, 7, 12, 20]
      tree = BST.from(values)

      final_tree =
        Enum.reduce(values, tree, fn value, acc ->
          BST.delete(acc, value)
        end)

      assert final_tree == nil
    end
  end

  describe "find_min/1" do
    test "finds minimum in a tree" do
      tree = BST.from([10, 5, 15, 3, 7, 12, 20])
      assert BST.find_min(tree) == 3
    end

    test "finds minimum when root is minimum" do
      tree = BST.from([10, 15, 20])
      assert BST.find_min(tree) == 10
    end

    test "finds minimum in single node tree" do
      tree = BST.new(42)
      assert BST.find_min(tree) == 42
    end
  end

  property "Deleting a value and then searching for it returns nil" do
    check all list <- nonempty(list_of(integer())),
              list = Enum.uniq(list),
              value <- member_of(list) do
      tree = BST.from(list)
      tree_after_delete = BST.delete(tree, value)

      assert BST.find(tree_after_delete, value) == nil
    end
  end

  property "Deleting a value maintains BST property (inorder is sorted)" do
    check all list <- nonempty(list_of(integer())),
              value <- member_of(list) do
      tree = BST.from(list)
      tree_after_delete = BST.delete(tree, value)

      if tree_after_delete do
        inorder = Traversal.inorder(tree_after_delete)
        assert inorder == Enum.sort(inorder)
      else
        # Tree became empty after deletion
        assert list == [value] or Enum.all?(list, &(&1 == value))
      end
    end
  end

  property "Deleting all unique values from tree results in nil" do
    check all list <- nonempty(list_of(integer())),
              unique_list = Enum.uniq(list),
              unique_list != [] do
      tree = BST.from(unique_list)

      final_tree =
        Enum.reduce(unique_list, tree, fn value, acc ->
          BST.delete(acc, value)
        end)

      assert final_tree == nil
    end
  end
end
