defmodule ExAlgo.StackTest do
  use ExUnit.Case
  @moduletag :stack

  doctest ExAlgo.Stack

  alias ExAlgo.Stack

  setup_all do
    {:ok,
     %{
       empty_stack: %Stack{},
       singleton_stack: %Stack{container: [1]},
       stack: %Stack{container: [1, 2, 3]}
     }}
  end

  describe "Creating stacks" do
    test "Creating an empty stack" do
      assert Stack.new() == %Stack{container: []}
    end

    test "Creating stack from enumerable" do
      assert Stack.from(1..4) == %Stack{container: [4, 3, 2, 1]}
    end
  end

  describe "Push into a stack" do
    test "Push numbers into an empty stack", %{empty_stack: empty_stack} do
      assert %Stack{container: [false, true]} ==
               empty_stack |> Stack.push(true) |> Stack.push(false)
    end

    test "Push numbers into non-empty stack", %{stack: stack} do
      assert %Stack{container: [5, 4, 1, 2, 3]} == stack |> Stack.push(4) |> Stack.push(5)
    end
  end

  describe "Pop from a stack" do
    test "Trying to pop from an empty stack results in an error", %{empty_stack: empty_stack} do
      assert {:error, :underflow} == empty_stack |> Stack.pop()
    end

    test "Pop from a non-empty stack", %{stack: stack} do
      {item, stack} = stack |> Stack.pop()
      assert item == 1
      assert stack.container == [2, 3]
    end

    test "Pop from a non-empty stack multiple times", %{stack: stack} do
      {item_1, stack} = stack |> Stack.pop()
      {item_2, stack} = stack |> Stack.pop()
      {item_3, stack} = stack |> Stack.pop()
      assert {:error, :underflow} == stack |> Stack.pop()
      assert {item_1, item_2, item_3} == {1, 2, 3}
    end
  end

  describe "Peek from a stack" do
    test "Trying to peek from an empty stack results in an error", %{empty_stack: empty_stack} do
      assert {:error, :underflow} == empty_stack |> Stack.peek()
    end

    test "Peek from a non-empty stack", %{stack: stack} do
      assert 1 == stack |> Stack.peek()
    end
  end

  describe "Stacks Inspect" do
    test "Inspect an empty stack", %{empty_stack: empty_stack} do
      assert inspect(empty_stack) == "#ExAlgo.Stack<[]>"
    end

    test "Inspect a stack with single element", %{singleton_stack: singleton_stack} do
      assert inspect(singleton_stack) == "#ExAlgo.Stack<[1]>"
    end

    test "Inspect a stack with multiple elements", %{stack: stack} do
      assert inspect(stack) == "#ExAlgo.Stack<[1, 2, 3]>"
    end
  end

  describe "Stacks as collectible" do
    test "Turn an empty list into an empty stack" do
      assert [] |> Enum.into(%Stack{}) == %Stack{container: []}
    end

    test "List gets into stack in reverse order" do
      assert 1..3 |> Enum.into(%Stack{}) == %Stack{container: [3, 2, 1]}
    end
  end

  describe "Stack as enumerable" do
    test "Length of a stack", stacks do
      assert Enum.count(stacks.empty_stack) == 0
      assert Enum.count(stacks.singleton_stack) == 1
      assert Enum.count(stacks.stack) == 3
    end

    test "Map over a stack", %{stack: stack} do
      assert Enum.map(stack, fn elem -> elem ** 2 end) == [1, 4, 9]
    end

    test "Filter over a stack", %{stack: stack} do
      assert Enum.filter(stack, fn elem -> elem > 1 end) == [2, 3]
    end

    test "Convert a stack to a set", %{stack: stack} do
      assert Enum.into(stack, %MapSet{}) == MapSet.new([1, 2, 3])
    end
  end
end
