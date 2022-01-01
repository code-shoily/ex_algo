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
end
