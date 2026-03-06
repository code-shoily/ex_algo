defmodule ExAlgo.Graph.Functional.Transform do
  @moduledoc """
  Higher-order transformations and operational functions for the functional inductive graph.

  This module provides functions that operate on the graph as a whole using the
  inductive primitives provided by `ExAlgo.Graph.Functional.Model`. These include
  mapping over nodes or labels, filtering nodes, and changing graph directionality.
  """

  alias ExAlgo.Graph.Functional.Model

  @doc "Performs a map operation over all nodes in the graph."
  @spec map_nodes(Model.t(), (Model.Context.t() -> Model.Context.t())) :: Model.t()
  def map_nodes(%Model{nodes: nodes} = graph, fun) do
    new_nodes = Map.new(nodes, fn {id, ctx} -> {id, fun.(ctx)} end)
    %{graph | nodes: new_nodes}
  end

  @doc "Filters nodes in the graph based on a predicate function."
  @spec filter_nodes(Model.t(), (Model.Context.t() -> boolean())) :: Model.t()
  def filter_nodes(%Model{nodes: nodes} = graph, fun) do
    nodes_to_remove =
      nodes
      |> Enum.reject(fn {_id, ctx} -> fun.(ctx) end)
      |> Enum.map(fn {id, _ctx} -> id end)

    Enum.reduce(nodes_to_remove, graph, fn id, acc ->
      {:ok, new_graph} = Model.remove_node(acc, id)
      new_graph
    end)
  end

  @doc "Folds over all nodes in the graph."
  @spec fold_nodes(Model.t(), acc, (Model.Context.t(), acc -> acc)) :: acc when acc: any()
  def fold_nodes(%Model{nodes: nodes}, initial, fun) do
    Enum.reduce(nodes, initial, fn {_id, ctx}, acc -> fun.(ctx, acc) end)
  end

  @doc "Transforms the labels of all nodes using the given function."
  @spec map_labels(Model.t(), (Model.node_label() -> Model.node_label())) :: Model.t()
  def map_labels(graph, fun) do
    map_nodes(graph, fn ctx -> %{ctx | label: fun.(ctx.label)} end)
  end

  @doc "Transforms the labels of all edges using the given function."
  @spec map_edge_labels(Model.t(), (Model.edge_label() -> Model.edge_label())) :: Model.t()
  def map_edge_labels(graph, fun) do
    map_nodes(graph, fn ctx ->
      %{
        ctx
        | in_edges: Map.new(ctx.in_edges, fn {id, label} -> {id, fun.(label)} end),
          out_edges: Map.new(ctx.out_edges, fn {id, label} -> {id, fun.(label)} end)
      }
    end)
  end

  @doc "Reverses the direction of all edges in a directed graph."
  @spec reverse(Model.t()) :: Model.t()
  def reverse(%Model{direction: :directed} = graph) do
    map_nodes(graph, fn ctx ->
      %{ctx | in_edges: ctx.out_edges, out_edges: ctx.in_edges}
    end)
  end

  def reverse(%Model{direction: :undirected} = graph), do: graph

  @doc "Converts an undirected graph to a directed one."
  @spec to_directed(Model.t()) :: Model.t()
  def to_directed(%Model{} = graph) do
    %{graph | direction: :directed}
  end

  @doc "Converts a directed graph to an undirected one by symmetrizing edges."
  @spec to_undirected(Model.t()) :: Model.t()
  def to_undirected(%Model{direction: :undirected} = graph), do: graph

  def to_undirected(%Model{direction: :directed} = graph) do
    new_graph = %{graph | direction: :undirected}

    fold_nodes(graph, new_graph, fn ctx, acc ->
      Enum.reduce(ctx.out_edges, acc, fn {neighbor_id, label}, inner_acc ->
        Model.add_undirected_edge!(inner_acc, ctx.id, neighbor_id, label)
      end)
    end)
  end
end
