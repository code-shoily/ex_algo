defmodule ExAlgo.Graph.Functional.AnalysisTest do
  use ExUnit.Case, async: true

  alias ExAlgo.Graph.Functional.Model, as: Graph
  alias ExAlgo.Graph.Functional.Analysis

  # ──────────────────────────────────────────────────────────────────────────────
  # Shared Fixtures
  # ──────────────────────────────────────────────────────────────────────────────

  # A single connected undirected component
  # 1 -- 2 -- 3
  # |    |
  # 4 -- 5
  defp connected_component do
    Graph.new(:undirected)
    |> Graph.ensure_node(1)
    |> Graph.ensure_node(2)
    |> Graph.ensure_node(3)
    |> Graph.ensure_node(4)
    |> Graph.ensure_node(5)
    |> Graph.add_edge!(1, 2)
    |> Graph.add_edge!(2, 3)
    |> Graph.add_edge!(1, 4)
    |> Graph.add_edge!(4, 5)
    |> Graph.add_edge!(2, 5)
  end

  # Two disconnected components: {1, 2, 3} and {4, 5}
  defp disconnected_components do
    Graph.new(:undirected)
    |> Graph.ensure_node(1)
    |> Graph.ensure_node(2)
    |> Graph.ensure_node(3)
    |> Graph.ensure_node(4)
    |> Graph.ensure_node(5)
    |> Graph.add_edge!(1, 2)
    |> Graph.add_edge!(2, 3)
    |> Graph.add_edge!(4, 5)
  end

  # Graph with a clear bridge and cut vertices
  # Triangle {1, 2, 3} connected to Triangle {4, 5, 6} via bridge (3, 4)
  #
  #  1 -- 2
  #  |   /
  #  |  /
  #  3
  #  |  <-- Bridge (3, 4)
  #  4
  #  |  \
  #  |   \
  #  5 -- 6
  defp bridge_graph do
    Graph.new(:undirected)
    |> Graph.ensure_node(1)
    |> Graph.ensure_node(2)
    |> Graph.ensure_node(3)
    |> Graph.ensure_node(4)
    |> Graph.ensure_node(5)
    |> Graph.ensure_node(6)
    |> Graph.add_edge!(1, 2)
    |> Graph.add_edge!(2, 3)
    |> Graph.add_edge!(1, 3)
    # The bridge
    |> Graph.add_edge!(3, 4)
    |> Graph.add_edge!(4, 5)
    |> Graph.add_edge!(5, 6)
    |> Graph.add_edge!(4, 6)
  end

  # A single ring/cycle (no bridges, no articulation points)
  defp ring_graph do
    Graph.new(:undirected)
    |> Graph.ensure_node(1)
    |> Graph.ensure_node(2)
    |> Graph.ensure_node(3)
    |> Graph.ensure_node(4)
    |> Graph.add_edge!(1, 2)
    |> Graph.add_edge!(2, 3)
    |> Graph.add_edge!(3, 4)
    |> Graph.add_edge!(4, 1)
  end

  # ──────────────────────────────────────────────────────────────────────────────
  # Connected Components Tests
  # ──────────────────────────────────────────────────────────────────────────────

  describe "connected_components/1" do
    test "empty graph returns empty list" do
      assert Analysis.connected_components(Graph.empty()) == []
    end

    test "single node returns one component" do
      graph = Graph.new(:undirected) |> Graph.ensure_node(1)
      assert [[1]] = Analysis.connected_components(graph)
    end

    test "fully connected components returns a single list" do
      [comp] = Analysis.connected_components(connected_component())
      assert Enum.sort(comp) == [1, 2, 3, 4, 5]
    end

    test "disconnected graph returns multiple components" do
      components = Analysis.connected_components(disconnected_components())
      assert length(components) == 2

      sorted_comps = components |> Enum.map(&Enum.sort/1) |> Enum.sort()
      assert sorted_comps == [[1, 2, 3], [4, 5]]
    end

    test "graph with isolated nodes treats them as separate components" do
      graph = disconnected_components() |> Graph.ensure_node(99)

      components = Analysis.connected_components(graph)
      assert length(components) == 3

      sorted_comps = components |> Enum.map(&Enum.sort/1) |> Enum.sort()
      assert sorted_comps == [[1, 2, 3], [4, 5], [99]]
    end
  end

  # ──────────────────────────────────────────────────────────────────────────────
  # Analyze Connectivity (Bridges & Articulation Points) Tests
  # ──────────────────────────────────────────────────────────────────────────────

  describe "analyze_connectivity/1" do
    test "empty graph returns empty results" do
      result = Analysis.analyze_connectivity(Graph.empty())
      assert result.bridges == []
      assert result.points == []
    end

    test "single node has no bridges or points" do
      graph = Graph.new(:undirected) |> Graph.ensure_node(42)
      result = Analysis.analyze_connectivity(graph)
      assert result.bridges == []
      assert result.points == []
    end

    test "single edge is a bridge, but no articulation point unless graph is larger" do
      graph =
        Graph.new(:undirected)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.add_edge!(1, 2)

      result = Analysis.analyze_connectivity(graph)

      # 1-2 is a bridge
      [{u, v}] = result.bridges
      assert Enum.sort([u, v]) == [1, 2]

      # Neither 1 nor 2 are articulation points since removing either
      # doesn't increase simply the number of connected components beyond the
      # removal of the node itself (by definition, endpoints of a single edge aren't APs)
      assert result.points == []
    end

    test "ring graph has no bridges and no articulation points" do
      result = Analysis.analyze_connectivity(ring_graph())
      assert result.bridges == []
      assert result.points == []
    end

    test "graph with a bridge and cut vertices correctly identifies them" do
      result = Analysis.analyze_connectivity(bridge_graph())

      # Bridge between 3 and 4
      assert length(result.bridges) == 1
      [{u, v}] = result.bridges
      assert Enum.sort([u, v]) == [3, 4]

      # Nodes 3 and 4 are cut vertices (articulation points)
      sorted_points = Enum.sort(result.points)
      assert sorted_points == [3, 4]
    end

    test "star graph (one central node) has all edges as bridges and center as AP" do
      graph =
        Graph.new(:undirected)
        # Center
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.ensure_node(3)
        |> Graph.ensure_node(4)
        |> Graph.ensure_node(5)
        |> Graph.add_edge!(1, 2)
        |> Graph.add_edge!(1, 3)
        |> Graph.add_edge!(1, 4)
        |> Graph.add_edge!(1, 5)

      result = Analysis.analyze_connectivity(graph)

      assert length(result.bridges) == 4
      assert result.points == [1]
    end

    test "handles disconnected components gracefully" do
      graph =
        Graph.new(:undirected)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        # Bridge
        |> Graph.add_edge!(1, 2)
        |> Graph.ensure_node(3)
        |> Graph.ensure_node(4)
        |> Graph.ensure_node(5)
        |> Graph.add_edge!(3, 4)
        |> Graph.add_edge!(4, 5)
        # Triangle, no bridges
        |> Graph.add_edge!(3, 5)

      result = Analysis.analyze_connectivity(graph)

      # Only 1-2 is a bridge
      assert length(result.bridges) == 1
      [{u, v}] = result.bridges
      assert Enum.sort([u, v]) == [1, 2]

      # No APs since components are small/rings
      assert result.points == []
    end
  end
end
