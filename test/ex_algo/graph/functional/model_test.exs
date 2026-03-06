defmodule ExAlgo.Graph.Functional.ModelTest do
  use ExUnit.Case, async: true
  alias ExAlgo.Graph.Functional.Model, as: Graph

  describe "core inductive operations" do
    setup do
      graph =
        Graph.empty()
        |> Graph.ensure_node(1, "A")
        |> Graph.ensure_node(2, "B")
        |> Graph.ensure_node(3, "C")
        |> Graph.add_edge!(1, 2, "e12")
        |> Graph.add_edge!(2, 3, "e23")
        |> Graph.add_edge!(3, 1, "e31")

      {:ok, graph: graph}
    end

    test "match/2 extracts a node and completely severs its incident edges", %{graph: graph} do
      assert {:ok, context, remainder} = Graph.match(graph, 2)

      assert context.id == 2
      assert context.label == "B"
      assert context.in_edges == %{1 => "e12"}
      assert context.out_edges == %{3 => "e23"}

      assert Graph.size(remainder) == 2
      refute Graph.has_node?(remainder, 2)

      assert {:ok, %{}} = Graph.out_neighbors(remainder, 1)
      assert {:ok, %{}} = Graph.in_neighbors(remainder, 3)

      assert Graph.has_edge?(remainder, 3, 1)
    end

    test "embed/2 restores a decomposed graph to its exact original state", %{
      graph: original_graph
    } do
      {:ok, context, remainder} = Graph.match(original_graph, 2)

      restored_graph = Graph.embed(context, remainder)

      assert restored_graph == original_graph
    end

    test "match/2 returns an error for a non-existent node", %{graph: graph} do
      assert {:error, :not_found} = Graph.match(graph, 99)
    end
  end

  describe "regression tests" do
    test "removing an edge to a non-existent node doesn't corrupt the graph" do
      graph =
        Graph.empty()
        |> Graph.ensure_node(1, "A")
        |> Graph.ensure_node(2, "B")
        |> Graph.add_edge!(1, 2, "edge")

      {:ok, new_graph} = Graph.remove_edge(graph, 1, 99)

      assert {:error, :not_found} = Graph.get_node(new_graph, 99)

      assert {:ok, ctx} = Graph.get_node(new_graph, 1)
      assert ctx.out_edges == %{2 => "edge"}
    end
  end

  describe "graph building and querying" do
    test "neighbors/2 returns unique adjacent nodes regardless of edge direction" do
      graph =
        Graph.empty()
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.add_edge!(1, 2)
        |> Graph.add_edge!(2, 1)

      assert {:ok, [2]} = Graph.neighbors(graph, 1)
    end
  end

  describe "directionality" do
    test "directed graphs only add edges in one direction" do
      graph =
        Graph.new(:directed)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.add_edge!(1, 2)

      assert Graph.has_edge?(graph, 1, 2)
      refute Graph.has_edge?(graph, 2, 1)
    end

    test "undirected graphs add edges in both directions" do
      graph =
        Graph.new(:undirected)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.add_edge!(1, 2)

      assert Graph.has_edge?(graph, 1, 2)
      assert Graph.has_edge?(graph, 2, 1)
    end
  end

  describe "helpers" do
    test "match_any/1 matches an arbitrary node" do
      graph =
        Graph.empty()
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)

      assert {:ok, _ctx, remainder} = Graph.match_any(graph)
      assert Graph.size(remainder) == 1
    end
  end

  test "embed/2 gracefully ignores missing neighbors without corrupting state" do
    original_graph =
      ExAlgo.Graph.Functional.Model.empty()
      |> ExAlgo.Graph.Functional.Model.ensure_node(1, "A")
      |> ExAlgo.Graph.Functional.Model.ensure_node(2, "B")
      |> ExAlgo.Graph.Functional.Model.ensure_node(3, "C")
      |> ExAlgo.Graph.Functional.Model.add_edge!(1, 2, "e12")
      |> ExAlgo.Graph.Functional.Model.add_edge!(2, 3, "e23")
      |> ExAlgo.Graph.Functional.Model.add_edge!(3, 1, "e31")

    {:ok, context, remainder} = ExAlgo.Graph.Functional.Model.match(original_graph, 2)

    {:ok, remainder_without_3} = ExAlgo.Graph.Functional.Model.remove_node(remainder, 3)

    restored_graph = ExAlgo.Graph.Functional.Model.embed(context, remainder_without_3)

    assert {:error, :not_found} = ExAlgo.Graph.Functional.Model.get_node(restored_graph, 3)

    assert ExAlgo.Graph.Functional.Model.size(restored_graph) == 2
  end
end
