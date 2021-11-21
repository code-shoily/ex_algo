defmodule ExAlgo.Stack do
  @moduledoc """
  A basic Stack implementation
  """

  @doc """
  The Stack struct.
  """
  defstruct container: []

  @type value_type :: any()
  @type t :: %__MODULE__{container: [value_type()]}

  @doc"""
  Create a new empty stack

  ## Example

    iex> alias ExAlgo.Stack
    iex> Stack.new()
    %Stack{container: []}

  """
  @spec new() :: t()
  def new, do: %__MODULE__{}

  @doc"""
  Create a new stack from an enumerable. Note that the stack container has the order inversed as each element of the
  iterable is pushed into the stack, thereby putting the last element on top.

  ## Example

    iex> alias ExAlgo.Stack
    iex> Stack.from(1..3)
    %Stack{container: [3, 2, 1]}

  """
  @spec from([value_type()]) :: t()
  def from(enumerable), do: enumerable |> Enum.into(%__MODULE__{})

  @doc """
  Puts an element on top of stack.

  ## Example:

    iex> alias ExAlgo.Stack
    iex> %Stack{} |> Stack.push(10) |> Stack.push(20)
    %Stack{container: [20, 10]}

  """
  @spec push(t(), value_type()) :: t()
  def push(%__MODULE__{container: container}, item) do
    %__MODULE__{container: [item | container]}
  end

  @doc """
  Extract an element from top of stack.

  ## Example:

    iex> alias ExAlgo.Stack
    iex> stack = %Stack{} |> Stack.push(10) |> Stack.push(20)
    iex> {20, %Stack{container: [10]}} = stack |> Stack.pop()

    iex> alias ExAlgo.Stack
    iex> {:error, :underflow} = %Stack{} |> Stack.pop()

  """
  @spec pop(t()) :: {value_type(), t()} | {:error, :underflow}
  def pop(%__MODULE__{container: []}) do
    {:error, :underflow}
  end

  def pop(%__MODULE__{container: [top | rest]}) do
    {top, %__MODULE__{container: rest}}
  end

  @doc """
  Extract an element from top of stack.

  ## Example:

    iex> alias ExAlgo.Stack
    iex> stack = %Stack{} |> Stack.push(10) |> Stack.push(20)
    iex> 20 = stack |> Stack.peek()

    iex> alias ExAlgo.Stack
    iex> %Stack{} |> Stack.peek()
    {:error, :underflow}

  """
  @spec peek(t()) :: value_type() | {:error, :underflow}
  def peek(%__MODULE__{container: []}) do
    {:error, :underflow}
  end

  def peek(%__MODULE__{container: [top | _]}), do: top
end
