defmodule ExAlgo.Heap.PairingHeap do
  @moduledoc """
  An implementation of a Pairing Heap.

  A pairing heap is a type of self-adjusting heap with excellent practical performance
  and a simple implementation. It is a multi-way tree that satisfies the heap property:
  the value of any node is less than or equal to the values of its children.

  Complexity:
  - `find_min`: O(1)
  - `insert`: O(1)
  - `merge`: O(1)
  - `delete_min`: O(log n) amortized

  The core merging strategy uses a two-pass approach to maintain balance without
  explicit height or rank tracking.
  """
  alias __MODULE__

  defmodule Node do
    @moduledoc "Represents a non-empty pairing heap node."
    defstruct [:value, children: []]
  end

  defmodule Empty do
    @moduledoc "Represents an empty pairing heap node."
    defstruct []
  end

  @doc "Creates a new empty pairing heap."
  def new, do: %Empty{}

  @doc "Inserts a value into the pairing heap."
  def insert(%Empty{}, value), do: node(value, [])
  def insert(heap, value), do: merge(heap, node(value, []))

  @doc "Returns the minimum element of the heap."
  def find_min(%Empty{}), do: {:error, :empty}
  def find_min(%Node{value: v}), do: {:ok, v}

  @doc "Removes the minimum element and combines the child sub-heaps."
  def delete_min(%Empty{}), do: {:error, :empty}
  def delete_min(%Node{children: c}), do: {:ok, combine(c)}

  def merge(h, %Empty{}), do: h
  def merge(%Empty{}, h), do: h

  def merge(%Node{value: v1, children: c1} = h1, %Node{value: v2, children: c2} = h2) do
    if v1 <= v2 do
      node(v1, [h2 | c1])
    else
      node(v2, [h1 | c2])
    end
  end

  def count(%Empty{}), do: 0
  def count(%Node{children: c}), do: 1 + Enum.reduce(c, 0, &(count(&1) + &2))

  defp node(v, children), do: %Node{value: v, children: children}
  defp combine([]), do: %Empty{}
  defp combine([h]), do: h
  # The classic two-pass pairing: merge pairs from left to right,
  # then merge the result of the second pass.
  defp combine([h1, h2 | rest]) do
    merge(merge(h1, h2), combine(rest))
  end

  defimpl ExAlgo.Visualizer, for: Empty do
    def suitable?(_), do: true
    def to_text(_), do: " (empty)"
    def to_mermaid(_), do: "graph TD\n  EMPTY[Empty Pairing Heap]"
  end

  defimpl ExAlgo.Visualizer, for: Node do
    alias ExAlgo.Heap.PairingHeap.{Empty, Node}

    def suitable?(node), do: PairingHeap.count(node) < 40

    def to_text(node), do: do_to_text(node, 0)

    def to_mermaid(node) do
      "graph TD\n" <> do_to_mermaid(node)
    end

    defp do_to_text(%Node{value: v, children: c}, indent) do
      IO.puts(String.duplicate("    ", indent) <> "└── #{v}")
      Enum.each(c, &do_to_text(&1, indent + 1))
    end

    defp do_to_text(%Empty{}, _indent), do: :ok

    defp do_to_mermaid(%Node{value: v, children: c} = n) do
      id = "n#{:erlang.phash2(n)}"
      label = "#{v}"

      connections =
        Enum.map_join(c, "", fn
          %Node{} = child ->
            child_id = "n#{:erlang.phash2(child)}"
            "  #{id} --- #{child_id}\n" <> do_to_mermaid(child)

          %Empty{} ->
            ""
        end)

      "  #{id}[\"#{label}\"]\n" <> connections
    end
  end
end
