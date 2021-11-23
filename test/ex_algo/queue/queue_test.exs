defmodule ExAlgo.QueueTest do
  use ExUnit.Case
  @moduletag :queue

  doctest ExAlgo.Queue

  alias ExAlgo.Queue

  describe "inspect" do
    test "inspect a queue" do
      assert inspect(Queue.new()) == "#ExAlgo.Queue<[]>"
      assert inspect(Queue.from([1])) == "#ExAlgo.Queue<[1]>"
      assert inspect(Queue.from(1..3)) == "#ExAlgo.Queue<[3, 2, 1]>"
    end
  end

  describe "collectable" do
    test "collect a list into a queue" do
      queue = for i <- 1..10, into: %Queue{}, do: i
      assert Queue.to_list(queue) == 1..10 |> Enum.to_list() |> Enum.reverse()
    end
  end

  describe "enum" do
    test "count" do
      assert Queue.new() |> Enum.empty?()
      assert Queue.from(1..4) |> Enum.count() == 4
      assert Queue.from(1..4) == Enum.into(1..4, %Queue{})
      assert Enum.into(1..4, %Queue{}) == %Queue{left: [4, 3, 2, 1], right: []}
      assert Queue.from(1..4) |> Enum.map(fn i -> i ** 2 end) == [16, 9, 4, 1]
    end
  end
end
