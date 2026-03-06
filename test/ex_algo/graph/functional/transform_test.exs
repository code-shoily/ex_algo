defmodule ExAlgo.Graph.Functional.TransformTest do
  use ExUnit.Case, async: true

  alias ExAlgo.Graph.Functional.Model, as: Graph
  alias ExAlgo.Graph.Functional.Transform

  describe "mapping" do
    test "map_nodes/2 transforms all node contexts" do
      graph =
        Graph.empty()
        |> Graph.ensure_node(1, "a")
        |> Graph.ensure_node(2, "b")

      upper_graph =
        Transform.map_nodes(graph, fn ctx ->
          %{ctx | label: String.upcase(ctx.label)}
        end)

      assert {:ok, %{label: "A"}} = Graph.get_node(upper_graph, 1)
      assert {:ok, %{label: "B"}} = Graph.get_node(upper_graph, 2)
    end

    test "map_labels/2 and map_edge_labels/2 apply functions directly to labels" do
      graph =
        Graph.empty()
        |> Graph.ensure_node(1, 10)
        |> Graph.ensure_node(2, 20)
        |> Graph.add_edge!(1, 2, 5)

      mapped =
        graph
        |> Transform.map_labels(fn x -> x * 2 end)
        |> Transform.map_edge_labels(fn x -> x + 1 end)

      assert {:ok, %{label: 20}} = Graph.get_node(mapped, 1)
      assert {:ok, %{label: 40}} = Graph.get_node(mapped, 2)
      assert {:ok, 6} = Graph.get_edge(mapped, 1, 2)
    end
  end

  describe "directionality transformations" do
    test "to_undirected/1 converts directed graph to undirected by symmetrizing edges" do
      graph =
        Graph.new(:directed)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.add_edge!(1, 2)
        |> Transform.to_undirected()

      assert graph.direction == :undirected
      assert Graph.has_edge?(graph, 1, 2)
      assert Graph.has_edge?(graph, 2, 1)
    end

    test "to_undirected/1 on an already undirected graph is a no-op" do
      graph = Graph.new(:undirected)
      assert Transform.to_undirected(graph).direction == :undirected
    end

    test "to_directed/1 converts undirected graph to directed" do
      graph = Graph.new(:undirected)
      assert Transform.to_directed(graph).direction == :directed
    end

    test "reverse/1 flips edges in directed graphs" do
      graph =
        Graph.new(:directed)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.add_edge!(1, 2)
        |> Transform.reverse()

      refute Graph.has_edge?(graph, 1, 2)
      assert Graph.has_edge?(graph, 2, 1)
    end

    test "reverse/1 is a no-op on undirected graphs" do
      graph =
        Graph.new(:undirected)
        |> Graph.ensure_node(1)
        |> Graph.ensure_node(2)
        |> Graph.add_edge!(1, 2)
        |> Transform.reverse()

      assert Graph.has_edge?(graph, 1, 2)
      assert Graph.has_edge?(graph, 2, 1)
    end
  end

  describe "filtering" do
    test "filter_nodes/2 removes nodes that fail predicate and their incident edges" do
      graph =
        Graph.empty()
        |> Graph.ensure_node(1, :keep)
        |> Graph.ensure_node(2, :drop)
        |> Graph.ensure_node(3, :keep)
        |> Graph.add_edge!(1, 2)
        |> Graph.add_edge!(2, 3)
        |> Graph.add_edge!(3, 1)

      filtered = Transform.filter_nodes(graph, fn ctx -> ctx.label == :keep end)

      assert Graph.has_node?(filtered, 1)
      assert Graph.has_node?(filtered, 3)
      refute Graph.has_node?(filtered, 2)

      # Remaining edge from 3->1 should exist
      assert Graph.has_edge?(filtered, 3, 1)
      # Edges involving 2 should be completely removed
      refute Graph.has_edge?(filtered, 1, 2)
      refute Graph.has_edge?(filtered, 2, 3)
    end
  end
end
