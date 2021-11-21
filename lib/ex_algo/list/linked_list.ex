defmodule ExAlgo.List.LinkedList do
  @moduledoc """
  Implementation of a singly linked list.
  """
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
  @spec remove(t()) :: {value_type(), t()} | {:error, :empty_list}
  def remove(%__MODULE__{container: []}), do: {:error, :empty_list}
  def remove(%__MODULE__{container: [head | rest]}), do: {head, %__MODULE__{container: rest}}
end
