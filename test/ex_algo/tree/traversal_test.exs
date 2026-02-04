defmodule ExAlgo.Tree.TraversalTest do
  use ExUnit.Case
  use ExUnitProperties
  @moduletag :tree_traversal

  alias ExAlgo.Tree.BinarySearchTree, as: BST
  alias ExAlgo.Tree.Traversal

  doctest ExAlgo.Tree.Traversal

  property "Round-trip: Level-order traversal can reconstruct the exact same tree" do
    check all list <- nonempty(list_of(integer())) do
      tree_original = BST.from(list)
      flattened = Traversal.levelorder(tree_original)
      tree_reconstructed = BST.from(flattened)
      assert tree_original == tree_reconstructed
    end
  end

  describe "inorder/1" do
    test "inorder traversal for nil is empty" do
      assert Enum.empty?(Traversal.inorder(nil))
    end
  end

  describe "preorder/1" do
    test "preorder traversal for nil is empty" do
      assert Enum.empty?(Traversal.preorder(nil))
    end
  end

  describe "postorder/1" do
    test "postorder traversal for nil is empty" do
      assert Enum.empty?(Traversal.postorder(nil))
    end
  end
end
