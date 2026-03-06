defmodule ExAlgo.Graph.Functional.TraversalTest do
  use ExUnit.Case, async: true

  alias ExAlgo.Graph.Functional.Model, as: Graph
  alias ExAlgo.Graph.Functional.Traversal

  # ──────────────────────────────────────────────────────────────────────────────
  # Shared graph fixtures
  # ──────────────────────────────────────────────────────────────────────────────

  # Simple directed DAG:
  #   1 → 2 → 4
  #   1 → 3 → 4
  defp dag do
    Graph.new(:directed)
    |> Graph.ensure_node(1)
    |> Graph.ensure_node(2)
    |> Graph.ensure_node(3)
    |> Graph.ensure_node(4)
    |> Graph.add_edge!(1, 2)
    |> Graph.add_edge!(1, 3)
    |> Graph.add_edge!(2, 4)
    |> Graph.add_edge!(3, 4)
  end

  # Linear chain: 1 → 2 → 3 → 4
  defp chain do
    Graph.new(:directed)
    |> Graph.ensure_node(1)
    |> Graph.ensure_node(2)
    |> Graph.ensure_node(3)
    |> Graph.ensure_node(4)
    |> Graph.add_edge!(1, 2)
    |> Graph.add_edge!(2, 3)
    |> Graph.add_edge!(3, 4)
  end

  # Directed cycle: 1 → 2 → 3 → 1
  defp cycle do
    Graph.new(:directed)
    |> Graph.ensure_node(1)
    |> Graph.ensure_node(2)
    |> Graph.ensure_node(3)
    |> Graph.add_edge!(1, 2)
    |> Graph.add_edge!(2, 3)
    |> Graph.add_edge!(3, 1)
  end

  # Two disconnected components: {1 → 2} and {3 → 4}
  defp disconnected do
    Graph.new(:directed)
    |> Graph.ensure_node(1)
    |> Graph.ensure_node(2)
    |> Graph.ensure_node(3)
    |> Graph.ensure_node(4)
    |> Graph.add_edge!(1, 2)
    |> Graph.add_edge!(3, 4)
  end

  # Undirected triangle: 1 — 2 — 3 — 1
  defp undirected_triangle do
    Graph.new(:undirected)
    |> Graph.ensure_node(1)
    |> Graph.ensure_node(2)
    |> Graph.ensure_node(3)
    |> Graph.add_edge!(1, 2)
    |> Graph.add_edge!(2, 3)
    |> Graph.add_edge!(1, 3)
  end

  # ──────────────────────────────────────────────────────────────────────────────
  # DFS tests
  # ──────────────────────────────────────────────────────────────────────────────

  describe "dfs/2" do
    test "empty graph returns empty list" do
      assert [] = Traversal.dfs(Graph.empty(), 1)
    end

    test "single isolated node returns just that node" do
      graph = Graph.new() |> Graph.ensure_node(42, "solo")
      [ctx] = Traversal.dfs(graph, 42)
      assert ctx.id == 42
    end

    test "visits all reachable nodes in linear chain" do
      ids = Traversal.dfs(chain(), 1) |> Enum.map(& &1.id)
      assert ids == [1, 2, 3, 4]
    end

    test "visits reachable nodes — not all nodes — starting from unreachable mid-chain" do
      ids = Traversal.dfs(chain(), 3) |> Enum.map(& &1.id)
      assert ids == [3, 4]
      refute 1 in ids
    end

    test "handles directed cycles without infinite loop (inductive guarantee)" do
      ids = Traversal.dfs(cycle(), 1) |> Enum.map(& &1.id)
      assert Enum.sort(ids) == [1, 2, 3]
      # Each node visited exactly once
      assert length(ids) == length(Enum.uniq(ids))
    end

    test "each node in result is visited exactly once" do
      ids = Traversal.dfs(dag(), 1) |> Enum.map(& &1.id)
      assert ids == Enum.uniq(ids)
    end

    test "DAG: node 1 is first, all four nodes are visited exactly once" do
      ids = Traversal.dfs(dag(), 1) |> Enum.map(& &1.id)
      assert List.first(ids) == 1
      assert Enum.sort(ids) == [1, 2, 3, 4]
      assert length(ids) == length(Enum.uniq(ids))
    end

    test "disconnected graph from start only visits reachable component" do
      ids = Traversal.dfs(disconnected(), 1) |> Enum.map(& &1.id)
      assert Enum.sort(ids) == [1, 2]
      refute 3 in ids
    end

    test "multiple start nodes visits from each in order" do
      ids = Traversal.dfs(disconnected(), [1, 3]) |> Enum.map(& &1.id)
      assert Enum.sort(ids) == [1, 2, 3, 4]
    end

    test "undirected graph: traversal follows edges in both directions" do
      ids = Traversal.dfs(undirected_triangle(), 1) |> Enum.map(& &1.id)
      assert Enum.sort(ids) == [1, 2, 3]
    end

    test "returns contexts with correct labels" do
      graph =
        Graph.new()
        |> Graph.ensure_node(1, "one")
        |> Graph.ensure_node(2, "two")
        |> Graph.add_edge!(1, 2)

      [c1, c2] = Traversal.dfs(graph, 1)
      assert c1.label == "one"
      assert c2.label == "two"
    end
  end

  # ──────────────────────────────────────────────────────────────────────────────
  # BFS tests
  # ──────────────────────────────────────────────────────────────────────────────

  describe "bfs/2" do
    test "empty graph returns empty list" do
      assert [] = Traversal.bfs(Graph.empty(), 1)
    end

    test "single isolated node returns just that node" do
      graph = Graph.new() |> Graph.ensure_node(99, "solo")
      [ctx] = Traversal.bfs(graph, 99)
      assert ctx.id == 99
    end

    test "visits all reachable nodes in linear chain" do
      ids = Traversal.bfs(chain(), 1) |> Enum.map(& &1.id)
      assert ids == [1, 2, 3, 4]
    end

    test "handles directed cycles without infinite loop (inductive guarantee)" do
      ids = Traversal.bfs(cycle(), 1) |> Enum.map(& &1.id)
      assert Enum.sort(ids) == [1, 2, 3]
      assert length(ids) == length(Enum.uniq(ids))
    end

    test "each node is visited exactly once" do
      ids = Traversal.bfs(dag(), 1) |> Enum.map(& &1.id)
      assert ids == Enum.uniq(ids)
    end

    test "DAG: BFS visits level-by-level — node 1 before 2 and 3, both before 4" do
      ids = Traversal.bfs(dag(), 1) |> Enum.map(& &1.id)
      assert List.first(ids) == 1
      assert List.last(ids) == 4
      assert Enum.all?([2, 3], &(&1 in ids))
    end

    test "disconnected graph from start only visits reachable component" do
      ids = Traversal.bfs(disconnected(), 1) |> Enum.map(& &1.id)
      assert Enum.sort(ids) == [1, 2]
      refute 3 in ids
    end

    test "multiple start nodes visits all components" do
      ids = Traversal.bfs(disconnected(), [1, 3]) |> Enum.map(& &1.id)
      assert Enum.sort(ids) == [1, 2, 3, 4]
    end

    test "undirected graph: traversal follows edges in both directions" do
      ids = Traversal.bfs(undirected_triangle(), 1) |> Enum.map(& &1.id)
      assert Enum.sort(ids) == [1, 2, 3]
    end

    test "BFS order is breadth-first: shorter paths before longer" do
      # Star graph: 1 → 2, 1 → 3, 1 → 4 (all neighbors at distance 1)
      star =
        Graph.new()
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.ensure_node(3)
        |> Graph.ensure_node(4)
        |> Graph.add_edge!(1, 2)
        |> Graph.add_edge!(1, 3)
        |> Graph.add_edge!(1, 4)

      [first | _] = Traversal.bfs(star, 1)
      assert first.id == 1
    end
  end

  # ──────────────────────────────────────────────────────────────────────────────
  # DFS vs BFS ordering comparison
  # ──────────────────────────────────────────────────────────────────────────────

  describe "dfs vs bfs ordering" do
    # Graph:
    #   1 → 2 → 4
    #   1 → 3
    # DFS from 1 explores depth-first: 1, 2, 4, 3
    # BFS from 1 explores 2 and 3 before going deeper
    defp wide_graph do
      Graph.new(:directed)
      |> Graph.ensure_node(1)
      |> Graph.ensure_node(2)
      |> Graph.ensure_node(3)
      |> Graph.ensure_node(4)
      |> Graph.add_edge!(1, 2)
      |> Graph.add_edge!(1, 3)
      |> Graph.add_edge!(2, 4)
    end

    test "DFS goes depth-first before backtracking" do
      ids = Traversal.dfs(wide_graph(), 1) |> Enum.map(& &1.id)
      # 1 is first, then 2 then 4 (depth branch), then 3
      assert ids == [1, 2, 4, 3]
    end

    test "BFS visits all nodes at depth 1 before depth 2" do
      ids = Traversal.bfs(wide_graph(), 1) |> Enum.map(& &1.id)
      # 1 first, then 2 and 3 (both at depth 1), then 4 (depth 2)
      assert List.first(ids) == 1
      assert List.last(ids) == 4
      # Both 2 and 3 appear before 4
      idx = fn id -> Enum.find_index(ids, &(&1 == id)) end
      assert idx.(2) < idx.(4)
      assert idx.(3) < idx.(4)
    end
  end
end
