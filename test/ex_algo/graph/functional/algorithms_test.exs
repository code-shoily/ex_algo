defmodule ExAlgo.Graph.Functional.AlgorithmsTest do
  use ExUnit.Case, async: true

  alias ExAlgo.Graph.Functional.Model, as: Graph
  alias ExAlgo.Graph.Functional.Algorithms

  # ──────────────────────────────────────────────────────────────────────────────
  # Shared fixtures
  # ──────────────────────────────────────────────────────────────────────────────

  # Simple DAG: 1 → 2 → 4, 1 → 3 → 4
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

  # Diamond dependency: 1 → 2 → 4, 1 → 3 → 4 (same as dag but explicit)
  defp diamond_dag, do: dag()

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

  # Weighted directed graph for Dijkstra
  #   1 --1--> 2 --1--> 4
  #   1 --4--> 3 --1--> 4  (longer route via 3)
  defp weighted_graph do
    Graph.new(:directed)
    |> Graph.ensure_node(1)
    |> Graph.ensure_node(2)
    |> Graph.ensure_node(3)
    |> Graph.ensure_node(4)
    |> Graph.add_edge!(1, 2, 1)
    |> Graph.add_edge!(1, 3, 4)
    |> Graph.add_edge!(2, 4, 1)
    |> Graph.add_edge!(3, 4, 1)
  end

  # Undirected weighted graph for Prim's MST
  #  1 --1-- 2 --2-- 4
  #  |              |
  #  3 -----5-------+
  defp weighted_undirected do
    Graph.new(:undirected)
    |> Graph.ensure_node(1)
    |> Graph.ensure_node(2)
    |> Graph.ensure_node(3)
    |> Graph.ensure_node(4)
    |> Graph.add_edge!(1, 2, 1)
    |> Graph.add_edge!(2, 4, 2)
    |> Graph.add_edge!(1, 3, 3)
    |> Graph.add_edge!(3, 4, 5)
  end

  # ──────────────────────────────────────────────────────────────────────────────
  # Topological Sort
  # ──────────────────────────────────────────────────────────────────────────────

  describe "topsort/1" do
    test "empty graph returns empty order" do
      assert {:ok, []} = Algorithms.topsort(Graph.empty())
    end

    test "single node has trivial topological order" do
      graph = Graph.new() |> Graph.ensure_node(1)
      assert {:ok, [1]} = Algorithms.topsort(graph)
    end

    test "linear chain is sorted correctly" do
      graph =
        Graph.new(:directed)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.ensure_node(3)
        |> Graph.add_edge!(1, 2)
        |> Graph.add_edge!(2, 3)

      assert {:ok, [1, 2, 3]} = Algorithms.topsort(graph)
    end

    test "DAG: all four nodes appear, 1 before 2 and 3, both before 4" do
      assert {:ok, order} = Algorithms.topsort(dag())
      assert Enum.sort(order) == [1, 2, 3, 4]

      idx = fn id -> Enum.find_index(order, &(&1 == id)) end
      assert idx.(1) < idx.(2)
      assert idx.(1) < idx.(3)
      assert idx.(2) < idx.(4)
      assert idx.(3) < idx.(4)
    end

    test "diamond dependency: 1 comes first, 4 comes last" do
      assert {:ok, order} = Algorithms.topsort(diamond_dag())
      assert List.first(order) == 1
      assert List.last(order) == 4
    end

    test "cycle returns :cycle_detected" do
      assert {:error, :cycle_detected} = Algorithms.topsort(cycle())
    end

    test "graph with self-loop is detected as cyclic" do
      graph =
        Graph.new()
        |> Graph.ensure_node(1)
        |> Graph.add_edge!(1, 1)

      assert {:error, :cycle_detected} = Algorithms.topsort(graph)
    end

    test "topological order satisfies all edge constraints" do
      assert {:ok, order} = Algorithms.topsort(dag())
      idx = fn id -> Enum.find_index(order, &(&1 == id)) end

      Graph.edges(dag())
      |> Enum.each(fn {from, to, _} ->
        assert idx.(from) < idx.(to),
               "Edge #{from} → #{to} violates topological order: #{inspect(order)}"
      end)
    end
  end

  # ──────────────────────────────────────────────────────────────────────────────
  # Dijkstra's Shortest Path
  # ──────────────────────────────────────────────────────────────────────────────

  describe "shortest_path/3" do
    test "no path in empty graph" do
      assert {:error, :no_path} = Algorithms.shortest_path(Graph.empty(), 1, 2)
    end

    test "start == target for existing node returns distance 0" do
      graph = Graph.new() |> Graph.ensure_node(1)
      assert {:ok, [1], 0} = Algorithms.shortest_path(graph, 1, 1)
    end

    test "start == target for non-existent node returns :no_path" do
      assert {:error, :no_path} = Algorithms.shortest_path(Graph.empty(), 99, 99)
    end

    test "direct edge: single step path" do
      graph =
        Graph.new()
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.add_edge!(1, 2, 5)

      assert {:ok, [1, 2], 5} = Algorithms.shortest_path(graph, 1, 2)
    end

    test "weighted: chooses lower-cost route over higher-cost" do
      # 1→2→4 costs 2, 1→3→4 costs 5 — should pick first route
      assert {:ok, path, dist} = Algorithms.shortest_path(weighted_graph(), 1, 4)
      assert dist == 2
      assert path == [1, 2, 4]
    end

    test "unweighted: nil labels default to weight 1" do
      graph =
        Graph.new()
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.ensure_node(3)
        |> Graph.add_edge!(1, 2)
        |> Graph.add_edge!(2, 3)

      assert {:ok, [1, 2, 3], 2} = Algorithms.shortest_path(graph, 1, 3)
    end

    test "no path between disconnected nodes" do
      graph =
        Graph.new()
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)

      assert {:error, :no_path} = Algorithms.shortest_path(graph, 1, 2)
    end

    test "directed graph: no path against edge direction" do
      graph =
        Graph.new(:directed)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.add_edge!(1, 2, 1)

      # There's a path 1→2 but not 2→1
      assert {:ok, [1, 2], 1} = Algorithms.shortest_path(graph, 1, 2)
      assert {:error, :no_path} = Algorithms.shortest_path(graph, 2, 1)
    end

    test "result path starts with start_id and ends with target_id" do
      assert {:ok, path, _dist} = Algorithms.shortest_path(weighted_graph(), 1, 4)
      assert List.first(path) == 1
      assert List.last(path) == 4
    end

    test "handles cycle without infinite recursion (inductive guarantee)" do
      # Adding a backward edge creates a cycle, Dijkstra must still terminate
      graph =
        Graph.new(:directed)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.ensure_node(3)
        |> Graph.add_edge!(1, 2, 1)
        |> Graph.add_edge!(2, 3, 1)
        |> Graph.add_edge!(3, 1, 1)

      assert {:ok, [1, 2, 3], 2} = Algorithms.shortest_path(graph, 1, 3)
    end
  end

  # ──────────────────────────────────────────────────────────────────────────────
  # Prim's Minimum Spanning Tree
  # ──────────────────────────────────────────────────────────────────────────────

  describe "mst_prim/1" do
    test "empty graph returns empty edge list" do
      assert {:ok, []} = Algorithms.mst_prim(Graph.empty())
    end

    test "single node returns empty edge list (no edges needed)" do
      graph = Graph.new() |> Graph.ensure_node(1)
      assert {:ok, []} = Algorithms.mst_prim(graph)
    end

    test "two connected nodes returns the single connecting edge" do
      graph =
        Graph.new(:undirected)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.add_edge!(1, 2, 3)

      assert {:ok, edges} = Algorithms.mst_prim(graph)
      assert length(edges) == 1
      {from, to, w} = List.first(edges)
      assert {from, to} in [{1, 2}, {2, 1}]
      assert w == 3
    end

    test "MST has exactly n-1 edges for a connected graph" do
      assert {:ok, edges} = Algorithms.mst_prim(weighted_undirected())
      # 4 nodes → MST must have 3 edges
      assert length(edges) == 3
    end

    test "MST picks minimum-weight edges" do
      assert {:ok, edges} = Algorithms.mst_prim(weighted_undirected())
      total_weight = Enum.sum(Enum.map(edges, fn {_, _, w} -> w end))
      # Optimal MST: 1-2(1) + 2-4(2) + 1-3(3) = 6
      assert total_weight == 6
    end

    test "MST does not include duplicate or cycle edges" do
      assert {:ok, edges} = Algorithms.mst_prim(weighted_undirected())
      # All endpoint sets should be unique (no repeated edge between same pair)
      endpoint_pairs = Enum.map(edges, fn {f, t, _} -> Enum.sort([f, t]) end)
      assert endpoint_pairs == Enum.uniq(endpoint_pairs)
    end

    test "disconnected graph: only spans the component of the starting node" do
      # Two disconnected components: {1-2} and {3-4}
      graph =
        Graph.new(:undirected)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.ensure_node(3)
        |> Graph.ensure_node(4)
        |> Graph.add_edge!(1, 2, 1)
        |> Graph.add_edge!(3, 4, 1)

      assert {:ok, edges} = Algorithms.mst_prim(graph)
      # Only 1 edge for one component (node_ids order is non-deterministic,
      # but we know only one component of 2 nodes will be spanned)
      assert length(edges) == 1
    end
  end

  # ──────────────────────────────────────────────────────────────────────────────
  # Strongly Connected Components (Kosaraju's)
  # ──────────────────────────────────────────────────────────────────────────────

  describe "scc/1" do
    test "empty graph returns empty list" do
      assert [] = Algorithms.scc(Graph.empty())
    end

    test "single node is its own SCC" do
      graph = Graph.new() |> Graph.ensure_node(1)
      assert [[1]] = Algorithms.scc(graph)
    end

    test "raises ArgumentError for undirected graphs" do
      graph = Graph.new(:undirected)
      assert_raise ArgumentError, fn -> Algorithms.scc(graph) end
    end

    test "DAG has exactly one SCC per node (n SCCs)" do
      # 1 → 2 → 4, 1 → 3 → 4  (no cycles)
      sccs = Algorithms.scc(dag())
      assert length(sccs) == 4
      assert Enum.all?(sccs, fn scc -> length(scc) == 1 end)
    end

    test "simple cycle is one single SCC" do
      sccs = Algorithms.scc(cycle())
      assert length(sccs) == 1
      assert Enum.sort(hd(sccs)) == [1, 2, 3]
    end

    test "graph with multiple distinct SCCs" do
      # SCC 1: 1 → 2 → 3 → 1
      # SCC 2: 4 → 5 → 4
      # SCC 3: 6 (isolated)
      # Cross edges: 3 → 4, 5 → 6
      graph =
        Graph.new(:directed)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.ensure_node(3)
        |> Graph.ensure_node(4)
        |> Graph.ensure_node(5)
        |> Graph.ensure_node(6)
        # SCC 1
        |> Graph.add_edge!(1, 2)
        |> Graph.add_edge!(2, 3)
        |> Graph.add_edge!(3, 1)
        # SCC 2
        |> Graph.add_edge!(4, 5)
        |> Graph.add_edge!(5, 4)
        # Cross-component edges (one-way!)
        |> Graph.add_edge!(3, 4)
        |> Graph.add_edge!(5, 6)

      sccs = Algorithms.scc(graph)

      assert length(sccs) == 3

      sorted_sccs = sccs |> Enum.map(&Enum.sort/1) |> Enum.sort()
      assert sorted_sccs == [[1, 2, 3], [4, 5], [6]]
    end

    test "disconnected components are found correctly" do
      # {1 → 2 → 1} and {3 → 4 → 3} (no edges between them)
      graph =
        Graph.new(:directed)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.ensure_node(3)
        |> Graph.ensure_node(4)
        |> Graph.add_edge!(1, 2)
        |> Graph.add_edge!(2, 1)
        |> Graph.add_edge!(3, 4)
        |> Graph.add_edge!(4, 3)

      sccs = Algorithms.scc(graph)
      assert length(sccs) == 2

      sorted_sccs = sccs |> Enum.map(&Enum.sort/1) |> Enum.sort()
      assert sorted_sccs == [[1, 2], [3, 4]]
    end
  end
end
