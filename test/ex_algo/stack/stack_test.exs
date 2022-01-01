defmodule ExAlgo.StackTest do
  use ExUnit.Case
  use ExUnitProperties
  @moduletag :stack

  alias ExAlgo.Stack

  doctest ExAlgo.Stack

  setup_all do
    {:ok,
     %{
       empty_stack: %Stack{},
       singleton_stack: %Stack{container: [1]},
       stack: %Stack{container: [1, 2, 3]}
     }}
  end

  describe "new/0" do
    test "create an empty stack" do
      assert Stack.new() == %Stack{container: []}
    end
  end

  describe "from/1" do
    test "create a stack from an enumerable" do
      assert Stack.from(1..4) == %Stack{container: [4, 3, 2, 1]}
    end

    property "creating a stack from a list always has the container in reversed order" do
      check all list <- list_of(integer()) do
        stack = Stack.from(list)
        assert stack.container == Enum.reverse(list)
      end
    end
  end

  describe "push/2" do
    test "push numbers into an empty stack", %{empty_stack: stack} do
      assert %Stack{container: [false, true]} ==
               stack |> Stack.push(true) |> Stack.push(false)
    end

    test "push numbers into non-empty stack", %{stack: stack} do
      assert %Stack{container: [5, 4, 1, 2, 3]} == stack |> Stack.push(4) |> Stack.push(5)
    end
  end

  describe "pop/1" do
    test "trying to pop from an empty stack results in an error", %{empty_stack: stack} do
      assert {:error, :underflow} == stack |> Stack.pop()
    end

    test "pop from a non-empty stack", %{stack: stack} do
      {item, stack} = stack |> Stack.pop()
      assert item == 1
      assert stack.container == [2, 3]
    end

    test "pop from a non-empty stack multiple times", %{stack: stack} do
      {item_1, stack} = stack |> Stack.pop()
      {item_2, stack} = stack |> Stack.pop()
      {item_3, stack} = stack |> Stack.pop()
      assert {:error, :underflow} == stack |> Stack.pop()
      assert {item_1, item_2, item_3} == {1, 2, 3}
    end
  end

  describe "peek/1" do
    test "trying to peek on an empty stack results in an error", %{empty_stack: stack} do
      assert {:error, :underflow} == stack |> Stack.peek()
    end

    test "peek on a non-empty stack", %{stack: stack} do
      assert 1 == stack |> Stack.peek()
    end
  end

  describe "inspect" do
    test "inspect an empty stack", %{empty_stack: stack} do
      assert inspect(stack) == "#ExAlgo.Stack<[]>"
    end

    test "inspect a single element stack", %{singleton_stack: stack} do
      assert inspect(stack) == "#ExAlgo.Stack<[1]>"
    end

    test "inspect a stack with multiple elements", %{stack: stack} do
      assert inspect(stack) == "#ExAlgo.Stack<[1, 2, 3]>"
    end
  end

  describe "collectable" do
    test "turn an empty list into an empty stack" do
      assert [] |> Enum.into(%Stack{}) == %Stack{container: []}
    end

    test "list gets into stack in reverse order" do
      assert 1..3 |> Enum.into(%Stack{}) == %Stack{container: [3, 2, 1]}
    end
  end

  describe "enumerable" do
    test "length of a stack", stacks do
      assert stacks.empty_stack |> Enum.empty?()
      assert Enum.count(stacks.singleton_stack) == 1
      assert Enum.count(stacks.stack) == 3
    end

    test "map over a stack", %{stack: stack} do
      assert Enum.map(stack, fn elem -> elem ** 2 end) == [1, 4, 9]
    end

    test "filter over a stack", %{stack: stack} do
      assert Enum.filter(stack, fn elem -> elem > 1 end) == [2, 3]
    end

    test "convert a stack to a set", %{stack: stack} do
      assert Enum.into(stack, %MapSet{}) == MapSet.new([1, 2, 3])
    end
  end
end
