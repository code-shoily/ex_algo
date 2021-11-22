defmodule ExAlgo.Queue do
  @moduledoc """
  A basic queue implementation.
  """
  @type underflow_error :: {:error, :underflow}
  @type value_type :: any()
  @type t :: %__MODULE__{left: [value_type()], right: [value_type()]}

  @doc """
  A queue consists of a left and a right list.
  """
  defstruct left: [], right: []

  @doc """
  Creates a new empty Queue.

  ## Example

      iex> alias ExAlgo.Queue
      iex> Queue.new()
      %Queue{left: [], right: []}

  """
  @spec new() :: t()
  def new, do: %__MODULE__{left: [], right: []}

  @doc """
  Creates a queue from a list.

  ## Example

      iex> alias ExAlgo.Queue
      iex> ExAlgo.Queue.from 1..3
      %Queue{left: [1, 2, 3], right: []}

  """
  @spec from(Enumerable.t()) :: t()
  def from(enumerable), do: %__MODULE__{left: Enum.to_list(enumerable), right: []}

  @doc """
  Enqueues item in left of the queue.

  ## Example

      iex> alias ExAlgo.Queue
      iex> Queue.new |> Queue.enqueue(10) |> Queue.enqueue(20)
      %Queue{left: [20, 10], right: []}

  """
  @spec enqueue(t(), value_type()) :: t()
  def enqueue(%__MODULE__{left: left} = queue, item), do: %{queue | left: [item | left]}

  @doc """
  Dequeues the last item from the list.

  ## Example

      iex> alias ExAlgo.Queue
      iex> 1..4 |> Queue.from() |> Queue.dequeue()
      {4, %Queue{left: [], right: [3, 2, 1]}}

      iex> alias ExAlgo.Queue
      iex> Queue.new |> Queue.dequeue()
      {:error, :underflow}

  """
  @spec dequeue(t()) :: {value_type(), t()} | underflow_error()
  def dequeue(%__MODULE__{left: [], right: []}), do: {:error, :underflow}
  def dequeue(%__MODULE__{right: [value | rest]} = queue), do: {value, %{queue | right: rest}}

  def dequeue(%__MODULE__{left: left}),
    do: %__MODULE__{left: [], right: Enum.reverse(left)} |> dequeue()

  @doc """
  Appends at the right of the list.

  ## Example

      iex> alias ExAlgo.Queue
      iex> Queue.new |> Queue.append(10)
      %Queue{left: [], right: [10]}

      iex> alias ExAlgo.Queue
      iex> {_, queue} = 1..4 |> Queue.from() |> Queue.dequeue()
      iex> queue |> Queue.enqueue(5) |> Queue.append(6)
      %Queue{left: [5], right: [6, 3, 2, 1]}

  """
  @spec append(t(), value_type()) :: t()
  def append(%__MODULE__{right: right} = queue, item), do: %{queue | right: [item | right]}

  @doc """
  Returns a list representation of the queue.

  ## Example

      iex> alias ExAlgo.Queue
      iex> Queue.new() |> Queue.to_list()
      []

      iex> alias ExAlgo.Queue
      iex> Queue.from(1..4) |> Queue.to_list()
      [1, 2, 3, 4]

      iex> alias ExAlgo.Queue
      iex> Queue.from(1..4)
      ...> |> Queue.dequeue()
      ...> |> then(fn {_, queue} -> queue end)
      ...> |> Queue.enqueue(-1)
      ...> |> Queue.append(10)
      ...> |> Queue.to_list()
      [-1, 1, 2, 3, 10]

  """
  @spec to_list(t()) :: List.t()
  def to_list(%__MODULE__{left: left, right: []}), do: left
  def to_list(%__MODULE__{left: [], right: right}), do: Enum.reverse(right)
  def to_list(%__MODULE__{left: left, right: right}), do: left ++ Enum.reverse(right)
end
