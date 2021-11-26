defmodule ExAlgo.List.CircularList do
  @moduledoc """
  Implementation of a circular list.
  """
  @type neg_index_error :: {:error, :negative_index}
  @type empty_error :: {:error, :empty_list}
  @type value_type :: any()
  @type t :: %__MODULE__{visited: [value_type()], upcoming: [value_type()]}

  defstruct visited: [], upcoming: []

  @doc """
  Creates an empty circular list.

  ## Example

    iex> CircularList.new
    %CircularList{visited: [], upcoming: []}

  """
  @spec new :: t()
  def new, do: %__MODULE__{visited: [], upcoming: []}

  @doc """
  Creates a circular list from a list

  ## Example

    iex> CircularList.from 1..3
    %CircularList{upcoming: [1, 2, 3]}

  """
  @spec from(Enumerable.t()) :: t()
  def from(enumerable), do: %__MODULE__{upcoming: Enum.to_list(enumerable)}

  @doc """
  Inserts a new element on the head of the list.

  ## Example

    iex> list = CircularList.from 1..3
    iex> list |> CircularList.insert(10)
    %CircularList{upcoming: [10, 1, 2, 3]}

  """
  @spec insert(t(), value_type()) :: t()
  def insert(%__MODULE__{upcoming: right}, element),
    do: %__MODULE__{upcoming: [element | right]}

  @doc """
  Rewinds the list back to initial.

  ## Example

    iex> CircularList.new == CircularList.new |> CircularList.rewind()
    true

    iex> list = CircularList.from 1..5
    iex> list ==
    ...>  list
    ...>  |> CircularList.next()
    ...>  |> CircularList.next()
    ...>  |> CircularList.next()
    ...>  |> CircularList.rewind()
    true

  """
  @spec rewind(t()) :: t()
  def rewind(%__MODULE__{visited: [], upcoming: _} = list), do: list

  def rewind(%__MODULE__{visited: visited, upcoming: upcoming}),
    do: %__MODULE__{visited: [], upcoming: Enum.reverse(visited) ++ upcoming}

  @doc """
  Removes the head.

  ## Example

    iex> list = CircularList.from 1..3
    iex> list |> CircularList.remove()
    {1, %CircularList{visited: [], upcoming: [2, 3]}}

    iex> CircularList.new() |> CircularList.remove()
    {:error, :empty_list}

    iex> 1..3
    ...> |> CircularList.from()
    ...> |> CircularList.next()
    ...> |> CircularList.next()
    ...> |> CircularList.next()
    ...> |> CircularList.remove()
    {1, %CircularList{visited: [], upcoming: [2, 3]}}

  """
  @spec remove(t()) :: {value_type(), t()} | empty_error()
  def remove(%__MODULE__{visited: [], upcoming: []}), do: {:error, :empty_list}
  def remove(%__MODULE__{visited: _, upcoming: []} = list), do: list |> rewind() |> remove()
  def remove(%__MODULE__{upcoming: [head | rest]}), do: {head, %__MODULE__{upcoming: rest}}

  @doc """
  Returns the head of the circular list

  ## Example

      iex> CircularList.from(1..10) |> CircularList.head()
      1

      iex> CircularList.new |> CircularList.head()
      {:error, :empty_list}

      iex> CircularList.from([1]) |> CircularList.next() |> CircularList.head()
      1

  """
  @spec head(t()) :: empty_error()
  def head(%__MODULE__{visited: [], upcoming: []}), do: {:error, :empty_list}
  def head(%__MODULE__{upcoming: [head | _]}), do: head

  def head(%__MODULE__{visited: left, upcoming: []}),
    do: head(%__MODULE__{visited: [], upcoming: Enum.reverse(left)})

  @doc """
  Moves the cursor forward.

  ## Example

      iex> CircularList.from(1..3) |> CircularList.next()
      %CircularList{visited: [1], upcoming: [2, 3]}

      iex> CircularList.from(1..3) |> CircularList.next() |> CircularList.next() |> CircularList.next()
      %CircularList{visited: [3, 2, 1], upcoming: []}

      iex> CircularList.from(1..2) |> CircularList.next() |> CircularList.next() |> CircularList.next()
      %CircularList{visited: [], upcoming: [1, 2]}

      iex> CircularList.new |> CircularList.next()
      {:error, :empty_list}

  """
  @spec next(t()) :: t() | empty_error()
  def next(%__MODULE__{visited: [], upcoming: []}), do: {:error, :empty_list}

  def next(%__MODULE__{visited: visited, upcoming: [head | next]}),
    do: %__MODULE__{visited: [head | visited], upcoming: next}

  def next(%__MODULE__{visited: visited, upcoming: []}),
    do: %__MODULE__{visited: [], upcoming: Enum.reverse(visited)}

  @doc """
  Return the element at index. Index is 0 based and must be positive. Errors on empty list.

  ## Example

      iex> alias ExAlgo.List.CircularList
      iex> CircularList.from(0..10) |> CircularList.at(3)
      3

      iex> alias ExAlgo.List.CircularList
      iex> CircularList.from(0..10) |> CircularList.at(13)
      2

  """
  @spec at(t(), value_type()) :: value_type() | empty_error() | neg_index_error()
  def at(%__MODULE__{visited: [], upcoming: []}, _), do: {:error, :empty_list}
  def at(_, index) when index < 0, do: {:error, :negative_index}
  def at(list, 0), do: list |> head()
  def at(%__MODULE__{upcoming: []} = list, index), do: list |> rewind() |> at(index)
  def at(list, index), do: list |> next() |> at(index - 1)

  @doc """
  Converts a circular list into a List.

  ## Example

      iex> CircularList.new() |> CircularList.to_list()
      []

      iex> CircularList.from(1..4)
      ...> |> CircularList.next()
      ...> |> CircularList.next()
      ...> |> CircularList.to_list()
      [1, 2, 3, 4]

  """
  @spec to_list(t()) :: [value_type()]
  def to_list(%__MODULE__{visited: visited, upcoming: upcoming}) do
    Enum.reverse(visited) ++ upcoming
  end
end
