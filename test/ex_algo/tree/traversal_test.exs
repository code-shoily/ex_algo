defmodule ExAlgo.Tree.TraversalTest do
  use ExUnit.Case
  @moduletag :tree_traversal

  doctest ExAlgo.Tree.Traversal

  alias ExAlgo.Tree.Traversal

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
