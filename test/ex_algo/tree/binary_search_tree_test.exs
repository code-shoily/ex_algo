defmodule ExAlgo.Tree.BinarySearchTreeTest do
  use ExUnit.Case
  use ExUnitProperties
  @moduletag :bst

  doctest ExAlgo.Tree.BinarySearchTree

  alias ExAlgo.Tree.BinarySearchTree
  alias ExAlgo.Tree.Traversal

  property "A list with a single element using `from` is the same as adding that as root" do
    check all value <- integer() do
      assert BinarySearchTree.new(value) == BinarySearchTree.from(List.wrap(value))
    end
  end

  property "Inorder traversal on a binary tree will produce sorted data" do
    check all list <- nonempty(list_of(integer())) do
      tree = BinarySearchTree.from(list)
      inorder_traversal = Traversal.inorder(tree)

      assert inorder_traversal == Enum.sort(list)
    end
  end
end
