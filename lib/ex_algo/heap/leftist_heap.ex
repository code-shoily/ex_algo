defmodule ExAlgo.Heap.LeftistHeap do
  @moduledoc """
  Implementation of a leftist heap.
  """
  alias __MODULE__

  defmodule Node do
    defstruct [:dist, :value, :left, :right]
  end

  defmodule Empty do
    defstruct []
  end

  def new(), do: %Empty{}

  def insert(%Empty{}, value), do: %Node{dist: 0, value: value, left: %Empty{}, right: %Empty{}}
  def insert(heap, value), do: merge(heap, insert(%Empty{}, value))

  def find_min(%Empty{}), do: {:error, :empty}
  def find_min(%Node{value: v}), do: {:ok, v}

  def delete_min(%Empty{}), do: {:error, :empty}
  def delete_min(%Node{left: l, right: r}), do: {:ok, merge(l, r)}

  def merge(h, %Empty{}), do: h
  def merge(%Empty{}, h), do: h

  def merge(h1 = %Node{value: v1}, h2 = %Node{value: v2}) do
    if v1 <= v2 do
      do_merge(h1, h2)
    else
      do_merge(h2, h1)
    end
  end

  def count(%Empty{}), do: 0
  def count(%Node{left: l, right: r}), do: 1 + count(l) + count(r)

  defp do_merge(%Node{value: v, left: l, right: r}, other) do
    merged_right = merge(r, other)

    if dist(l) < dist(merged_right) do
      node(v, merged_right, l)
    else
      node(v, l, merged_right)
    end
  end

  defp node(value, left, right) do
    %Node{dist: dist(right) + 1, value: value, left: left, right: right}
  end

  defp dist(%Empty{}), do: -1
  defp dist(%Node{dist: d}), do: d

  defimpl ExAlgo.Visualizer, for: Empty do
    def suitable?(_), do: true
    def to_text(_), do: " (empty)"
    def to_mermaid(_), do: "graph TD\n  EMPTY[Empty Heap]"
  end

  defimpl ExAlgo.Visualizer, for: Node do
    def suitable?(node), do: LeftistHeap.count(node) < 30

    def to_text(node), do: do_to_text(node, 0)

    def to_mermaid(node) do
      "graph TD\n" <> do_mermaid(node)
    end

    defp do_to_text(%Empty{}, indent), do: IO.puts(String.duplicate("    ", indent) <> "nil")

    defp do_to_text(%Node{dist: d, value: v, left: l, right: r}, indent) do
      do_to_text(r, indent + 1)
      IO.puts(String.duplicate("    ", indent) <> "── #{v} (d:#{d})")
      do_to_text(l, indent + 1)
    end

    defp do_mermaid(%Empty{}), do: ""

    defp do_mermaid(%Node{dist: d, value: v, left: l, right: r} = n) do
      id = "n#{:erlang.phash2(n)}"
      label = "#{v} (d:#{d})"
      left_str = connect(id, l, "L")
      right_str = connect(id, r, "R")

      "  #{id}[\"#{label}\"]\n" <> left_str <> right_str <> do_mermaid(l) <> do_mermaid(r)
    end

    defp connect(pid, %Empty{}, side), do: "  #{pid} --- nil_#{side}_#{pid}(nil)\n"

    defp connect(pid, %Node{} = child, _side) do
      "  #{pid} --- n#{:erlang.phash2(child)}\n"
    end
  end
end
