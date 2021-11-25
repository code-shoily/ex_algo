defmodule ExAlgo.Tree.BinarySearchTree do
  @moduledoc """
  Implements a binary search tree.
  """
  @type key_type :: any()
  @type value_type :: any()
  @type key_fn :: (value_type() -> key_type())
  @type leaf :: nil
  @type t() :: %__MODULE__{
          data: value_type(),
          left: t() | leaf(),
          right: t() | leaf()
        }

  @identity &Function.identity/1

  @doc """
  A binary tree contains data, left child and right child
  """
  defstruct [:data, left: nil, right: nil]

  @doc """
  Create a new tree with data being the root.

  ## Example

      iex> alias ExAlgo.Tree.BinarySearchTree, as: BST
      iex> BST.new(0)
      %BST{data: 0, left: nil, right: nil}

      iex> alias ExAlgo.Tree.BinarySearchTree, as: BST
      iex> BST.new(%{id: 10, name: "Mafinar"})
      %BST{data: %{id: 10, name: "Mafinar"}, left: nil, right: nil}

  """
  def new(data), do: %__MODULE__{data: data}

  @doc """
  Creates a binary search tree from a list.

  ## Example

      iex> alias ExAlgo.Tree.BinarySearchTree, as: BST
      iex> BST.from [5, 4, 7]
      %BST{
        data: 5,
        left: %BST{
          data: 4,
          left: nil,
          right: nil
        },
        right: %BST{
          data: 7,
          left: nil,
          right: nil
        }
      }
  """
  @spec from([value_type()]) :: t()
  def from([x | xs]) do
    xs
    |> Enum.reduce(
      __MODULE__.new(x),
      fn item, tree -> tree |> insert(item) end
    )
  end

  @doc """
  Insert a new item in the correct position in the tree.

  ## Example

      iex> alias ExAlgo.Tree.BinarySearchTree, as: BST
      iex> BST.new(10)
      ...> |> BST.insert(11)
      ...> |> BST.insert(-34)
      ...> |> BST.insert(14)
      ...> |> BST.insert(0)
      ...> |> BST.insert(-75)
      %BST{
        data: 10,
        left: %BST{
          data: -34,
          left: %BST{
            data: -75,
            left: nil,
            right: nil
          },
          right: %BST{
            data: 0,
            left: nil,
            right: nil
          },
        },
        right: %BST{
          data: 11,
          left: nil,
          right: %BST{
            data: 14,
            left: nil,
            right: nil
          },
        }
      }

  """
  @spec insert(t(), value_type()) :: t()
  def insert(%__MODULE__{data: data, left: left} = tree, item) when item < data do
    case left do
      nil -> %{tree | left: %__MODULE__{data: item}}
      left -> %{tree | left: insert(left, item)}
    end
  end

  def insert(%__MODULE__{right: right} = tree, item) do
    case right do
      nil -> %{tree | right: %__MODULE__{data: item}}
      right -> %{tree | right: insert(right, item)}
    end
  end

  @doc """
  Find an item on the tree.

  ## Example

      iex> alias ExAlgo.Tree.BinarySearchTree, as: BST
      iex> tree = BST.from [10, 11, -34, 14, 0, -75]
      iex> BST.find(tree, 11)
      11
      iex> BST.find(tree, 9)
      nil

      iex> alias ExAlgo.Tree.BinarySearchTree, as: BST
      iex> languages = [
      ...>  %{id: 1, language: "Elixir"},
      ...>  %{id: 2, language: "Python"},
      ...>  %{id: 3, language: "C++"}
      ...> ]
      iex> tree = BST.from(languages)
      iex> BST.find(tree, 2, & &1.id)
      %{id: 2, language: "Python"}
      iex> BST.find(tree, 6, & &1.id)
      nil

  """
  @spec find(t() | nil, key_type(), key_fn()) :: nil | value_type()
  def find(_, _, key_fn \\ @identity)
  def find(nil, _, _), do: nil

  def find(%__MODULE__{data: data, left: left, right: right}, key, key_fn) do
    case key_fn.(data) do
      ^key -> data
      current_key when current_key < key -> find(right, key, key_fn)
      _ -> find(left, key, key_fn)
    end
  end
end
