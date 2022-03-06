defmodule ExAlgo.Stack.MinMaxStackTest do
  use ExUnit.Case
  use ExUnitProperties
  @moduletag :min_max_stack

  alias ExAlgo.Stack.MinMaxStack

  doctest MinMaxStack

  describe "from" do
    property "from creates the properties in reverse order" do
      check all list <- list_of(integer()) do
        stack = MinMaxStack.from(list)
        assert stack.container |> Enum.map(& &1.current) == Enum.reverse(list)
      end
    end
  end

  describe "current" do
    property "current value returns the last element" do
      check all list <- nonempty list_of(integer()) do
        stack = MinMaxStack.from(list)
        assert MinMaxStack.current(stack) == List.last(list)
      end
    end
  end

  describe "minimum" do
    property "minimum always returns the smallest value" do
      check all list <- nonempty list_of(integer()) do
        stack = MinMaxStack.from(list)
        assert MinMaxStack.minimum(stack) == Enum.min(list)
      end
    end
  end

  describe "maximum" do
    property "maximum always returns the biggest value" do
      check all list <- nonempty list_of(integer()) do
        stack = MinMaxStack.from(list)
        assert MinMaxStack.maximum(stack) == Enum.max(list)
      end
    end
  end
end
