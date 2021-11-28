defmodule ExAlgo.List.BidirectionalList do
  @moduledoc """
  Implementation of bidirectional list using Zipper.
  """
  @type error :: {:error, :start_of_list} | {:error, :end_of_list} | {:error, :empty}
  @type value_type :: any()
  @type t :: %__MODULE__{visited: list(value_type()), upcoming: list(value_type())}

  defstruct visited: [], upcoming: []

  @doc """
  Creates a new empty list.

  ## Example

      iex> BidirectionalList.new()
      %BidirectionalList{visited: [], upcoming: []}

  """
  @spec new :: t()
  def new, do: %__MODULE__{visited: [], upcoming: []}

  @doc """
  Creates a new bidirectional list from a list.

  ## Example

      iex> BidirectionalList.from(1..3)
      %BidirectionalList{visited: [], upcoming: [1, 2, 3]}

  """
  @spec from([value_type()]) :: t()
  def from(list), do: %__MODULE__{visited: [], upcoming: Enum.to_list(list)}

  @doc """
  Insert a new element on a list. After insertion, this value becomes the current.

  ## Example

      iex> BidirectionalList.new()
      ...> |> BidirectionalList.insert(10)
      ...> |> BidirectionalList.insert(20)
      ...> |> BidirectionalList.insert(30)
      %BidirectionalList{visited: [], upcoming: [30, 20, 10]}

  """
  @spec insert(t(), value_type()) :: t()
  def insert(%__MODULE__{upcoming: upcoming} = list, item),
    do: %__MODULE__{list | upcoming: [item | upcoming]}

  @doc """
  Returns the current element of a bidirectional list

  ## Example

      iex> BidirectionalList.new() |> BidirectionalList.current()
      {:error, :empty}

      iex> BidirectionalList.from(1..3) |> BidirectionalList.current()
      1

      iex> BidirectionalList.new()
      ...> |> BidirectionalList.insert(10)
      ...> |> BidirectionalList.insert(20)
      ...> |> BidirectionalList.current()
      20

  """
  @spec current(t()) :: value_type() | error()
  def current(%__MODULE__{visited: [], upcoming: []}), do: {:error, :empty}
  def current(%__MODULE__{visited: [], upcoming: [current | _]}), do: current

  @doc """
  Move the cursor forward and return the new list.

  ## Example

      iex> BidirectionalList.new |> BidirectionalList.next()
      {:error, :empty}

      iex> BidirectionalList.from(1..3) |> BidirectionalList.next()
      %BidirectionalList{visited: [1], upcoming: [2, 3]}

      iex> BidirectionalList.from(1..3)
      ...> |> BidirectionalList.next()
      ...> |> BidirectionalList.next()
      ...> |> BidirectionalList.next()
      ...> |> BidirectionalList.next()
      {:error, :end_of_list}

  """
  @spec next(t()) :: t() | error()
  def next(%__MODULE__{visited: [], upcoming: []}), do: {:error, :empty}
  def next(%__MODULE__{visited: _, upcoming: []}), do: {:error, :end_of_list}

  def next(%__MODULE__{visited: visited, upcoming: [current | rest]}) do
    %__MODULE__{visited: [current | visited], upcoming: rest}
  end

  @doc """
  Move the cursor backwards and return the new list.

  ## Example

      iex> BidirectionalList.new |> BidirectionalList.previous()
      {:error, :empty}

      iex> BidirectionalList.from(1..3) |> BidirectionalList.previous()
      {:error, :start_of_list}

      iex> BidirectionalList.from(1..3)
      ...> |> BidirectionalList.next()
      ...> |> BidirectionalList.next()
      ...> |> BidirectionalList.previous()
      %BidirectionalList{visited: [1], upcoming: [2, 3]}

      iex> BidirectionalList.from(1..3)
      ...> |> BidirectionalList.next()
      ...> |> BidirectionalList.previous()
      %BidirectionalList{visited: [], upcoming: [1, 2, 3]}

  """
  @spec previous(t()) :: t() | error()
  def previous(%__MODULE__{visited: [], upcoming: []}), do: {:error, :empty}
  def previous(%__MODULE__{visited: [], upcoming: _}), do: {:error, :start_of_list}

  def previous(%__MODULE__{visited: [current | rest], upcoming: upcoming}) do
    %__MODULE__{visited: rest, upcoming: [current | upcoming]}
  end
end
