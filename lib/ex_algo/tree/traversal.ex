defmodule ExAlgo.Tree.Traversal do
  @moduledoc """
  Performs traversals on Binary Trees.
  """
  @type item :: any()
  @type items :: [any()]
  @type tree :: %{data: item(), left: tree | nil, right: tree | nil}

  @doc """
  Traverses a tree inorder.

  ## Example

      iex> alias ExAlgo.Tree.BinarySearchTree, as: BST
      iex> alias ExAlgo.Tree.Traversal
      iex> tree = BST.from([30, 20, 40, 15, 25, 35, 50, 5, 18, 45, 60])
      iex> tree |> Traversal.inorder()
      [5, 15, 18, 20, 25, 30, 35, 40, 45, 50, 60]

  """
  @spec inorder(tree() | nil) :: items()
  def inorder(%{data: data, left: left, right: right}) do
    inorder(left) ++ [data] ++ inorder(right)
  end
  def inorder(nil), do: []

  @doc """
  Traverses a tree preorder.

  ## Example

      iex> alias ExAlgo.Tree.BinarySearchTree, as: BST
      iex> alias ExAlgo.Tree.Traversal
      iex> tree = BST.from([30, 20, 40, 15, 25, 35, 50, 5, 18, 45, 60])
      iex> tree |> Traversal.preorder()
      [30, 20, 15, 5, 18, 25, 40, 35, 50, 45, 60]

  """
  @spec preorder(tree()) :: items()
  def preorder(%{data: data, left: left, right: right}) do
    [data] ++ preorder(left) ++ preorder(right)
  end
  def preorder(nil), do: []

  @doc """
  Traverses a tree postorder.

  ## Example

      iex> alias ExAlgo.Tree.BinarySearchTree, as: BST
      iex> alias ExAlgo.Tree.Traversal
      iex> tree = BST.from([30, 20, 40, 15, 25, 35, 50, 5, 18, 45, 60])
      iex> tree |> Traversal.postorder()
      [5, 18, 15, 25, 20, 35, 45, 60, 50, 40, 30]

  """
  @spec postorder(tree()) :: items()
  def postorder(%{data: data, left: left, right: right}) do
    postorder(left) ++ postorder(right) ++ [data]
  end
  def postorder(nil), do: []
end
