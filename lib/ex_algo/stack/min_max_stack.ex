defmodule ExAlgo.Stack.MinMaxStack do
  @moduledoc """
  A min-max stack. In addition to being a LIFO, this stack also keeps track of
  the smallest and largest values. And can efficiently show them. In addition to
  `push`, `pop`, and `peek`, a `MinMaxStack` also pop_minimum and pop_maximum
  values.1
  """

  defstruct container: []

  @type item() :: any()
  @type history() :: [item()]
  @type frame() :: %{top: item(), minimum: item(), maximum: item()}
  @type t() :: %__MODULE__{container: [frame()]}

  @doc """
  Create a new empty stack

  ## Example

    iex> MinMaxStack.new()
    %MinMaxStack{container: []}

  """
  def new, do: %__MODULE__{}

  @doc """
  Create a new min-max stack from an enumerable.

  Note that the stack container has the order inversed as each element of the
  iterable is pushed into the stack, thereby putting the last element on top.

  ## Example

      iex> MinMaxStack.from([])
      %MinMaxStack{container: []}

      iex> MinMaxStack.from(1..3)
      %MinMaxStack{container: [
        %{current: 3, maximum: 3, minimum: 1},
        %{current: 2, maximum: 2, minimum: 1},
        %{current: 1, maximum: 1, minimum: 1}
      ]}

      iex> MinMaxStack.from([7, -1, 5])
      %MinMaxStack{container: [
        %{current: 5, maximum: 7, minimum: -1},
        %{current: -1, maximum: 7, minimum: -1},
        %{current: 7, maximum: 7, minimum: 7}
      ]}

  """
  @spec from([item()]) :: t()
  def from(enumerable), do: Enum.reduce(enumerable, new(), &push(&2, &1))

  @doc """
  Returns the current item (aka top) of the stack.

  ## Example

      iex> MinMaxStack.new() |> MinMaxStack.current()
      nil

      iex> stack =
      ...>    MinMaxStack.new()
      ...>    |> MinMaxStack.push(10)
      ...>    |> MinMaxStack.push(-23)
      ...>    |> MinMaxStack.push(5)
      iex> stack |> MinMaxStack.current()
      5

  """
  @spec current(t()) :: item()
  def current(stack), do: stack |> extract(:current)

  @doc """
  Returns the minimum item of the stack.

  ## Example

      iex> MinMaxStack.new() |> MinMaxStack.minimum()
      nil

      iex> stack =
      ...>    MinMaxStack.new()
      ...>    |> MinMaxStack.push(10)
      ...>    |> MinMaxStack.push(-23)
      ...>    |> MinMaxStack.push(5)
      iex> stack |> MinMaxStack.minimum()
      -23

  """
  @spec minimum(t()) :: item()
  def minimum(stack), do: stack |> extract(:minimum)

  @doc """
  Returns the maximum item of the stack.

  ## Example

      iex> MinMaxStack.new() |> MinMaxStack.maximum()
      nil

      iex> stack =
      ...>    MinMaxStack.new()
      ...>    |> MinMaxStack.push(10)
      ...>    |> MinMaxStack.push(-23)
      ...>    |> MinMaxStack.push(5)
      iex> stack |> MinMaxStack.maximum()
      10

  """
  @spec maximum(t()) :: item()
  def maximum(stack), do: stack |> extract(:maximum)

  @doc """
  Pushes the value into the stack.

  ## Example

      iex> stack = MinMaxStack.new() |> MinMaxStack.push(10)
      iex> stack
      %MinMaxStack{container: [%{current: 10, maximum: 10, minimum: 10}]}
      iex> stack = stack |> MinMaxStack.push(-1)
      iex> stack
      %MinMaxStack{container: [
        %{current: -1, maximum: 10, minimum: -1},
        %{current: 10, maximum: 10, minimum: 10}
      ]}
      iex> stack = stack |> MinMaxStack.push(7)
      iex> stack
      %MinMaxStack{container: [
        %{current: 7, maximum: 10, minimum: -1},
        %{current: -1, maximum: 10, minimum: -1},
        %{current: 10, maximum: 10, minimum: 10}
      ]}

  """
  @spec push(t(), item()) :: t()
  def push(%__MODULE__{container: container} = stack, item) do
    new_frame = %{
      current: item,
      minimum: min(item, minimum(stack)),
      maximum: max(item, maximum(stack) || item)
    }

    %__MODULE__{container: [new_frame | container]}
  end

  @doc """
  Returns the top frame of the stack.

  ## Example

      iex> MinMaxStack.new() |> MinMaxStack.peek()
      nil

      iex> stack =
      ...>    MinMaxStack.new()
      ...>    |> MinMaxStack.push(10)
      ...>    |> MinMaxStack.push(-23)
      ...>    |> MinMaxStack.push(5)
      iex> stack |> MinMaxStack.peek()
      %{current: 5, minimum: -23, maximum: 10}

  """
  @spec peek(t()) :: frame() | nil
  def peek(%__MODULE__{container: []}), do: nil
  def peek(%__MODULE__{container: [current | _]}), do: current

  @doc """
  Pops the top-most frame from the stack.

  ## Example

      iex> MinMaxStack.new() |> MinMaxStack.pop()
      nil

      iex> MinMaxStack.from([4, 7, 0, -3]) |> MinMaxStack.pop()
      {-3, %MinMaxStack{container: [
        %{current: 0, minimum: 0, maximum: 7},
        %{current: 7, minimum: 4, maximum: 7},
        %{current: 4, minimum: 4, maximum: 4}
      ]}}

      iex> MinMaxStack.from([4, 7, 0, 30]) |> MinMaxStack.pop()
      {30, %MinMaxStack{container: [
        %{current: 0, minimum: 0, maximum: 7},
        %{current: 7, minimum: 4, maximum: 7},
        %{current: 4, minimum: 4, maximum: 4}
      ]}}
  """
  @spec pop(t()) :: {item(), t()} | nil
  def pop(%__MODULE__{container: []}), do: nil

  def pop(%__MODULE__{container: [%{current: val} | rest]}),
    do: {val, %__MODULE__{container: rest}}

  @doc """
  Pops the minimum value from the stack. Note that this will only remove once the
  minimum value is reached. In case of multiple repetition of that minimum value
  it will only pop once. Therefore, when there is duplicate values, `pop_minimum`
  will not change the minimum attirbute of the frame.

  It will return a tuple containing `{minimum_value, popped_values, new_stack}`

  ## Example

      iex> MinMaxStack.new() |> MinMaxStack.pop_minimum()
      nil

      iex> MinMaxStack.from([4, -7, 0, -3]) |> MinMaxStack.pop_minimum()
      {
        -7,
        [-7, 0, -3],
        %MinMaxStack{container: [%{current: 4, minimum: 4, maximum: 4}]}
      }

      iex> MinMaxStack.from([4, 7, 0, 0, 30]) |> MinMaxStack.pop_minimum()
      {0, [0, 30], %MinMaxStack{container: [
        %{current: 0, minimum: 0, maximum: 7},
        %{current: 7, minimum: 4, maximum: 7},
        %{current: 4, minimum: 4, maximum: 4}
      ]}}

      iex> MinMaxStack.from([-4, 7, 0, 0, 30]) |> MinMaxStack.pop_minimum()
      {-4, [-4, 7, 0, 0, 30], %MinMaxStack{container: []}}

  """
  @spec pop_minimum(t()) :: {item(), history(), t()} | nil
  def pop_minimum(%__MODULE__{container: []}), do: nil

  def pop_minimum(stack) do
    do_pop_minimum(stack, [])
  end

  defp do_pop_minimum(
         %__MODULE__{container: [%{current: minimum, minimum: minimum} | rest]},
         history
       ) do
    {minimum, [minimum | history], %__MODULE__{container: rest}}
  end

  defp do_pop_minimum(%__MODULE__{container: [%{current: current} | rest]}, history) do
    do_pop_minimum(%__MODULE__{container: rest}, [current | history])
  end

  @doc """
  Pops the maximum value from the stack. Note that this will only remove once the
  maximum value is reached. In case of multiple repetition of that maximum value
  it will only pop once. Therefore, when there is duplicate values, `pop_maximum`
  will not change the maximum attirbute of the frame.

  It will return a tuple containing `{maximum_value, popped_values, new_stack}`

  ## Example

      iex> MinMaxStack.new() |> MinMaxStack.pop_maximum()
      nil

      iex> MinMaxStack.from([4, 17, 0, -3]) |> MinMaxStack.pop_maximum()
      {
        17,
        [17, 0, -3],
        %MinMaxStack{container: [%{current: 4, minimum: 4, maximum: 4}]}
      }

      iex> MinMaxStack.from([4, 7, 10, 10, -30]) |> MinMaxStack.pop_maximum()
      {10, [10, -30], %MinMaxStack{container: [
        %{current: 10, minimum: 4, maximum: 10},
        %{current: 7, minimum: 4, maximum: 7},
        %{current: 4, minimum: 4, maximum: 4}
      ]}}

      iex> MinMaxStack.from([45, 7, 10, 10, -30]) |> MinMaxStack.pop_maximum()
      {45, [45, 7, 10, 10, -30], %MinMaxStack{container: []}}

  """
  @spec pop_maximum(t()) :: {item(), history(), t()} | nil
  def pop_maximum(%__MODULE__{container: []}), do: nil

  def pop_maximum(stack) do
    do_pop_maximum(stack, [])
  end

  defp do_pop_maximum(
         %__MODULE__{container: [%{current: maximum, maximum: maximum} | rest]},
         history
       ) do
    {maximum, [maximum | history], %__MODULE__{container: rest}}
  end

  defp do_pop_maximum(%__MODULE__{container: [%{current: current} | rest]}, history) do
    do_pop_maximum(%__MODULE__{container: rest}, [current | history])
  end

  defp extract(%__MODULE__{container: []}, _), do: nil
  defp extract(%__MODULE__{container: [%{minimum: val} | _]}, :minimum), do: val
  defp extract(%__MODULE__{container: [%{maximum: val} | _]}, :maximum), do: val
  defp extract(%__MODULE__{container: [%{current: val} | _]}, :current), do: val
end
