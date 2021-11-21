defmodule ExAlgo.List.LinkedList do
  @moduledoc """
  Implementation of a singly linked list.
  """
  @type neg_index_error :: {:error, :negative_index}
  @type empty_error :: {:error, :empty_list}
  @type value_type :: any()
  @type t :: %__MODULE__{container: [value_type()]}

  defstruct container: []

  @doc """
  Creates an empty linked list.

  ## Example

    iex> alias ExAlgo.List.LinkedList
    iex> LinkedList.new
    %LinkedList{container: []}

  """
  @spec new :: t()
  def new, do: %__MODULE__{container: []}

  @doc """
  Creates an empty linked list from a list

  ## Example

    iex> alias ExAlgo.List.LinkedList
    iex> LinkedList.from 1..3
    %LinkedList{container: [1, 2, 3]}

  """
  @spec from(Enumerable.t()) :: t()
  def from(enumerable), do: %__MODULE__{container: Enum.to_list(enumerable)}

  @doc """
  Inserts a new element on the head of the list.

  ## Example

    iex> alias ExAlgo.List.LinkedList
    iex> list = LinkedList.from 1..3
    iex> list |> LinkedList.insert(10)
    %LinkedList{container: [10, 1, 2, 3]}

  """
  @spec insert(t(), value_type()) :: t()
  def insert(%__MODULE__{container: container}, element),
    do: %__MODULE__{container: [element | container]}

  @doc """
  Removes the head.

  ## Example

    iex> alias ExAlgo.List.LinkedList
    iex> list = LinkedList.from 1..3
    iex> list |> LinkedList.remove()
    {1, %LinkedList{container: [2, 3]}}

    iex> alias ExAlgo.List.LinkedList
    iex> LinkedList.new() |> LinkedList.remove()
    {:error, :empty_list}

  """
  @spec remove(t()) :: {value_type(), t()} | empty_error()
  def remove(%__MODULE__{container: []}), do: {:error, :empty_list}
  def remove(%__MODULE__{container: [head | rest]}), do: {head, %__MODULE__{container: rest}}

  @doc """
  Returns the head of the linked list

  ## Example

      iex> alias ExAlgo.List.LinkedList
      iex> LinkedList.from(1..10) |> LinkedList.head()
      1

      iex> alias ExAlgo.List.LinkedList
      iex> LinkedList.new |> LinkedList.head()
      {:error, :empty_list}

  """
  @spec head(t()) :: empty_error()
  def head(%__MODULE__{container: [head | _]}), do: head
  def head(_), do: {:error, :empty_list}

  @doc """
  Returns the tail of the linked list

  ## Example

      iex> alias ExAlgo.List.LinkedList
      iex> LinkedList.from(1..3) |> LinkedList.tail()
      [2, 3]

      iex> alias ExAlgo.List.LinkedList
      iex> LinkedList.new |> LinkedList.tail()
      {:error, :empty_list}

  """
  @spec tail(t()) :: empty_error()
  def tail(%__MODULE__{container: [_ | tail]}), do: tail
  def tail(_), do: {:error, :empty_list}

  @doc """
  Return the element at index. Index is 0 based and must be positive. Errors on empty list.

  ## Example

      iex> alias ExAlgo.List.LinkedList
      iex> LinkedList.from(0..10) |> LinkedList.at(3)
      3

  """
  @spec at(t(), value_type()) :: value_type() | empty_error() | neg_index_error()
  def at(%__MODULE__{container: []}, _), do: {:error, :empty_list}
  def at(_, index) when index < 0, do: {:error, :negative_index}
  def at(list, 0), do: list |> head()
  def at(list, index), do: list |> tail |> from |> at(index - 1)
end
