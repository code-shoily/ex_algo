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

      iex> tree = BST.from([30, 20, 40, 15, 25, 35, 50, 5, 18, 45, 60])
      iex> tree |> Traversal.inorder()
      [5, 15, 18, 20, 25, 30, 35, 40, 45, 50, 60]

  """
  @spec inorder(tree() | nil) :: items()
  def inorder(tree), do: do_inorder(tree, [])

  defp do_inorder(nil, acc), do: acc

  defp do_inorder(%{data: data, left: left, right: right}, acc) do
    acc = do_inorder(right, acc)
    acc = [data | acc]
    do_inorder(left, acc)
  end

  @doc """
  Traverses a tree preorder.

  ## Example

      iex> tree = BST.from([30, 20, 40, 15, 25, 35, 50, 5, 18, 45, 60])
      iex> tree |> Traversal.preorder()
      [30, 20, 15, 5, 18, 25, 40, 35, 50, 45, 60]

  """
  @spec preorder(tree()) :: items()
  def preorder(tree), do: do_preorder(tree, [])

  defp do_preorder(nil, acc), do: acc

  defp do_preorder(%{data: data, left: left, right: right}, acc) do
    acc = do_preorder(right, acc)
    acc = do_preorder(left, acc)
    [data | acc]
  end

  @doc """
  Traverses a tree postorder.

  ## Example

      iex> tree = BST.from([30, 20, 40, 15, 25, 35, 50, 5, 18, 45, 60])
      iex> tree |> Traversal.postorder()
      [5, 18, 15, 25, 20, 35, 45, 60, 50, 40, 30]

  """
  @spec postorder(tree()) :: items()
  def postorder(tree), do: do_postorder(tree, [])

  defp do_postorder(nil, acc), do: acc

  defp do_postorder(%{data: data, left: left, right: right}, acc) do
    acc = [data | acc]
    acc = do_postorder(right, acc)
    do_postorder(left, acc)
  end
end
