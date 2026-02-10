defmodule ExAlgo.Graph.Functional.MST do
  @moduledoc """
  Minimum Spanning Tree algorithms for functional graphs.

  This module provides algorithms to find the minimum spanning tree (MST)
  of a weighted, undirected graph:
  - Kruskal's algorithm using disjoint set (union-find)
  - Prim's algorithm using priority queue

  ## Note on Directed Graphs

  MST algorithms are typically defined for undirected graphs. If you apply
  these to a directed graph, the algorithms will treat it as undirected
  (considering both in-edges and out-edges).
  """

  alias ExAlgo.Graph.Functional.Model
  alias ExAlgo.Set.DisjointSet
  alias ExAlgo.Heap.PairingHeap

  @type node_id :: Model.node_id()
  @type edge :: {node_id(), node_id(), Model.edge_label()}
  @type weight :: number()
  @type mst_result :: {:ok, [edge()], weight()} | {:error, atom()}

  @doc """
  Finds the minimum spanning tree using Kruskal's algorithm.

  This algorithm works by sorting all edges by weight and greedily adding
  edges that don't create cycles, using a disjoint set (union-find) to
  track connected components.

  Returns `{:ok, edges, total_weight}` where edges is a list of
  `{from, to, weight}` tuples representing the MST, or `{:error, reason}`.

  ## Complexity
  - Time: O(E log E) for sorting edges
  - Space: O(V) for the disjoint set

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2, 1); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 3, 3); g end)
      iex> {:ok, edges, weight} = kruskal(graph)
      iex> length(edges)
      2
      iex> weight
      3
  """
  @spec kruskal(Model.t()) :: mst_result()
  def kruskal(graph) do
    nodes = Model.node_ids(graph)

    if Enum.empty?(nodes) do
      {:ok, [], 0}
    else
      edges = get_undirected_edges(graph)
      kruskal_with_edges(nodes, edges)
    end
  end

  @doc """
  Finds the minimum spanning tree using Prim's algorithm.

  This algorithm grows the MST by starting from an arbitrary node and
  repeatedly adding the minimum-weight edge that connects a tree vertex
  to a non-tree vertex.

  Returns `{:ok, edges, total_weight}` or `{:error, reason}`.

  ## Complexity
  - Time: O(E log V) with a binary heap
  - Space: O(V)

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2, 1); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 3, 3); g end)
      iex> {:ok, edges, weight} = prim(graph)
      iex> length(edges)
      2
      iex> weight
      3
  """
  @spec prim(Model.t()) :: mst_result()
  def prim(graph) do
    nodes = Model.node_ids(graph)

    case nodes do
      [] -> {:ok, [], 0}
      [start | _] -> prim_from_node(graph, start)
    end
  end

  @doc """
  Finds the minimum spanning tree using Prim's algorithm starting from a specific node.

  Returns `{:ok, edges, total_weight}` or `{:error, reason}`.
  """
  @spec prim(Model.t(), node_id()) :: mst_result()
  def prim(graph, start_node) do
    if Model.has_node?(graph, start_node) do
      prim_from_node(graph, start_node)
    else
      {:error, :start_node_not_found}
    end
  end

  @doc """
  Checks if a graph is connected (has a spanning tree).

  This is useful to verify before computing an MST, as a graph must be
  connected to have a spanning tree.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2, 1); g end)
      iex> connected?(graph)
      false
  """
  @spec connected?(Model.t()) :: boolean()
  def connected?(graph) do
    nodes = Model.node_ids(graph)

    case nodes do
      [] -> true
      [start | _] ->
        visited = bfs_connected(graph, start, MapSet.new())
        MapSet.size(visited) == length(nodes)
    end
  end

  # Private functions for Kruskal's algorithm

  defp kruskal_with_edges(nodes, edges) do
    # Create mapping from node IDs to indices for DisjointSet
    {node_to_idx, _idx_to_node} = create_node_mappings(nodes)

    # Initialize disjoint set
    disjoint_set = DisjointSet.new(map_size(node_to_idx))

    # Sort edges by weight
    sorted_edges = Enum.sort_by(edges, fn {_from, _to, weight} -> weight || 0 end)

    # Process edges
    {mst_edges, total_weight, _final_ds} =
      Enum.reduce_while(sorted_edges, {[], 0, disjoint_set}, fn {from, to, weight}, {mst_acc, weight_acc, ds} ->
        from_idx = Map.fetch!(node_to_idx, from)
        to_idx = Map.fetch!(node_to_idx, to)
        edge_weight = weight || 0

        # Check if nodes are in different sets (adding edge won't create cycle)
        case {DisjointSet.find(ds, from_idx), DisjointSet.find(ds, to_idx)} do
          {{root_from, _ds1}, {root_to, ds2}} when root_from != root_to ->
            # Add edge to MST and union the sets
            ds3 = DisjointSet.union(ds2, from_idx, to_idx)
            new_mst = [{from, to, weight} | mst_acc]
            new_weight = weight_acc + edge_weight

            # Check if we have n-1 edges (complete MST)
            if length(new_mst) == map_size(node_to_idx) - 1 do
              {:halt, {new_mst, new_weight, ds3}}
            else
              {:cont, {new_mst, new_weight, ds3}}
            end

          {{_root_from, _ds1}, {_root_to, ds2}} ->
            # Nodes already connected, skip edge
            {:cont, {mst_acc, weight_acc, ds2}}
        end
      end)

    # Check if we have a complete spanning tree
    expected_edges = length(nodes) - 1
    if length(mst_edges) == expected_edges do
      {:ok, Enum.reverse(mst_edges), total_weight}
    else
      {:error, :disconnected_graph}
    end
  end

  defp create_node_mappings(nodes) do
    nodes_with_idx = Enum.with_index(nodes)
    node_to_idx = Map.new(nodes_with_idx)
    idx_to_node = Map.new(nodes_with_idx, fn {node, idx} -> {idx, node} end)
    {node_to_idx, idx_to_node}
  end

  # Private functions for Prim's algorithm

  defp prim_from_node(graph, start_node) do
    # Initialize
    visited = MapSet.new([start_node])
    pq = PairingHeap.new()

    # Add all edges from start node to priority queue
    pq = add_edges_to_pq(graph, start_node, pq)

    # Build MST
    prim_loop(graph, pq, visited, [], 0)
  end

  defp prim_loop(graph, pq, visited, mst_edges, total_weight) do
    case PairingHeap.find_min(pq) do
      {:ok, {weight, from, to}} ->
        {:ok, new_pq} = PairingHeap.delete_min(pq)

        # Skip if both nodes already visited
        if to in visited do
          prim_loop(graph, new_pq, visited, mst_edges, total_weight)
        else
          # Add edge to MST
          edge_weight = weight || 0
          new_mst = [{from, to, weight} | mst_edges]
          new_total = total_weight + edge_weight
          new_visited = MapSet.put(visited, to)

          # Add edges from newly added node
          new_pq = add_edges_to_pq(graph, to, new_pq)

          prim_loop(graph, new_pq, new_visited, new_mst, new_total)
        end

      {:error, :empty} ->
        # Done - check if we visited all nodes
        all_nodes = Model.node_ids(graph)
        if MapSet.size(visited) == length(all_nodes) do
          {:ok, Enum.reverse(mst_edges), total_weight}
        else
          {:error, :disconnected_graph}
        end
    end
  end

  defp add_edges_to_pq(graph, node, pq) do
    # Get all neighbors (both incoming and outgoing for undirected behavior)
    {:ok, out_neighbors} = Model.out_neighbors(graph, node)
    {:ok, in_neighbors} = Model.in_neighbors(graph, node)

    all_neighbors = Map.merge(out_neighbors, in_neighbors)

    Enum.reduce(all_neighbors, pq, fn {neighbor, weight}, acc ->
      PairingHeap.insert(acc, {weight || 0, node, neighbor})
    end)
  end

  # Helper function to get undirected edges (avoid duplicates)
  defp get_undirected_edges(graph) do
    edges = Model.edges(graph)

    # For undirected graph representation, we need to consider both directions
    # but avoid counting the same edge twice
    all_edges = Enum.flat_map(edges, fn {from, to, weight} ->
      # Check if reverse edge exists
      case Model.get_edge(graph, to, from) do
        {:ok, _} ->
          # Both directions exist - only include if from < to to avoid duplicates
          if compare_nodes(from, to) == :lt do
            [{from, to, weight}]
          else
            []
          end

        {:error, :not_found} ->
          # Only one direction - include it
          [{from, to, weight}]
      end
    end)

    # Also add reverse direction edges that weren't in the original edge list
    reverse_edges = Enum.flat_map(edges, fn {from, to, _weight} ->
      case Model.get_edge(graph, to, from) do
        {:ok, reverse_weight} ->
          # Reverse edge exists
          if compare_nodes(to, from) == :lt and compare_nodes(to, from) != :eq do
            [{to, from, reverse_weight}]
          else
            []
          end

        {:error, :not_found} ->
          []
      end
    end)

    Enum.uniq(all_edges ++ reverse_edges)
  end

  defp compare_nodes(a, b) when a < b, do: :lt
  defp compare_nodes(a, b) when a > b, do: :gt
  defp compare_nodes(_, _), do: :eq

  # BFS for connectivity check
  defp bfs_connected(graph, start, visited) do
    visited = MapSet.put(visited, start)
    {:ok, out_neighbors} = Model.out_neighbors(graph, start)
    {:ok, in_neighbors} = Model.in_neighbors(graph, start)

    neighbors = Map.merge(out_neighbors, in_neighbors) |> Map.keys()

    Enum.reduce(neighbors, visited, fn neighbor, acc ->
      if neighbor in acc do
        acc
      else
        bfs_connected(graph, neighbor, acc)
      end
    end)
  end
end
