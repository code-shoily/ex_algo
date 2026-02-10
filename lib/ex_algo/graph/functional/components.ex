defmodule ExAlgo.Graph.Functional.Components do
  @moduledoc """
  Graph connectivity and component analysis algorithms.

  This module provides algorithms for finding:
  - Connected components (undirected graphs)
  - Strongly connected components (directed graphs) using Kosaraju's algorithm
  - Weakly connected components (directed graphs treated as undirected)
  """

  alias ExAlgo.Graph.Functional.Model

  @type node_id :: Model.node_id()
  @type component :: [node_id()]
  @type component_map :: %{node_id() => non_neg_integer()}

  @doc """
  Finds all connected components in an undirected graph.

  Returns a list of components, where each component is a list of node IDs.
  For directed graphs, this treats all edges as undirected.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> Model.ensure_node(4)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 3, 4); g end)
      iex> components = connected_components(graph)
      iex> length(components)
      2
  """
  @spec connected_components(Model.t()) :: [component()]
  def connected_components(graph) do
    nodes = Model.node_ids(graph)
    find_components(graph, nodes, MapSet.new(), [])
  end

  @doc """
  Returns a map from each node to its component ID.

  Nodes in the same component have the same component ID.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      iex> component_map = component_membership(graph)
      iex> component_map[1] == component_map[2]
      true
      iex> component_map[1] != component_map[3]
      true
  """
  @spec component_membership(Model.t()) :: component_map()
  def component_membership(graph) do
    components = connected_components(graph)

    components
    |> Enum.with_index()
    |> Enum.flat_map(fn {component, idx} ->
      Enum.map(component, fn node -> {node, idx} end)
    end)
    |> Map.new()
  end

  @doc """
  Checks if two nodes are in the same connected component.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      iex> same_component?(graph, 1, 2)
      true
      iex> same_component?(graph, 1, 3)
      false
  """
  @spec same_component?(Model.t(), node_id(), node_id()) :: boolean()
  def same_component?(graph, node1, node2) do
    membership = component_membership(graph)
    membership[node1] == membership[node2]
  end

  @doc """
  Returns the number of connected components in the graph.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      iex> count_components(graph)
      2
  """
  @spec count_components(Model.t()) :: non_neg_integer()
  def count_components(graph) do
    length(connected_components(graph))
  end

  @doc """
  Checks if the graph is connected (has exactly one component).

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      iex> connected?(graph)
      true
  """
  @spec connected?(Model.t()) :: boolean()
  def connected?(graph) do
    count_components(graph) <= 1
  end

  @doc """
  Finds all strongly connected components (SCCs) in a directed graph.

  Uses Kosaraju's algorithm, which performs two depth-first searches:
  1. DFS on original graph to get finishing times
  2. DFS on transposed graph in reverse finishing time order

  Returns a list of SCCs, where each SCC is a list of node IDs.

  ## Complexity
  - Time: O(V + E)
  - Space: O(V)

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 3, 1); g end)
      iex> sccs = strongly_connected_components(graph)
      iex> length(sccs)
      1
      iex> Enum.sort(hd(sccs))
      [1, 2, 3]
  """
  @spec strongly_connected_components(Model.t()) :: [component()]
  def strongly_connected_components(graph) do
    # Step 1: Run DFS to compute finishing times
    nodes = Model.node_ids(graph)
    {_visited, finish_stack} = first_dfs(graph, nodes)

    # Step 2: Create transposed graph
    transposed = transpose_graph(graph)

    # Step 3: Run DFS on transposed graph in reverse finishing order
    find_sccs(transposed, finish_stack, MapSet.new(), [])
  end

  @doc """
  Returns a map from each node to its strongly connected component ID.

  Nodes in the same SCC have the same component ID.
  """
  @spec scc_membership(Model.t()) :: component_map()
  def scc_membership(graph) do
    sccs = strongly_connected_components(graph)

    sccs
    |> Enum.with_index()
    |> Enum.flat_map(fn {scc, idx} ->
      Enum.map(scc, fn node -> {node, idx} end)
    end)
    |> Map.new()
  end

  @doc """
  Checks if two nodes are in the same strongly connected component.
  """
  @spec same_scc?(Model.t(), node_id(), node_id()) :: boolean()
  def same_scc?(graph, node1, node2) do
    membership = scc_membership(graph)
    membership[node1] == membership[node2]
  end

  @doc """
  Returns the number of strongly connected components in the graph.
  """
  @spec count_sccs(Model.t()) :: non_neg_integer()
  def count_sccs(graph) do
    length(strongly_connected_components(graph))
  end

  @doc """
  Checks if the directed graph is strongly connected.

  A directed graph is strongly connected if there is a path from every
  node to every other node.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 1); g end)
      iex> strongly_connected?(graph)
      true
  """
  @spec strongly_connected?(Model.t()) :: boolean()
  def strongly_connected?(graph) do
    count_sccs(graph) <= 1
  end

  @doc """
  Finds weakly connected components in a directed graph.

  A weakly connected component is a maximal set of nodes where there is
  an undirected path between any pair (ignoring edge direction).

  This is equivalent to finding connected components after treating all
  edges as undirected.
  """
  @spec weakly_connected_components(Model.t()) :: [component()]
  def weakly_connected_components(graph) do
    connected_components(graph)
  end

  @doc """
  Creates a condensation graph from the strongly connected components.

  The condensation graph is a DAG where each node represents an SCC,
  and there's an edge between two SCCs if there's an edge between any
  nodes in those SCCs in the original graph.

  Returns `{condensation_graph, scc_list}` where:
  - condensation_graph: A graph where nodes are SCC indices
  - scc_list: List of SCCs (same order as indices)

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      iex> {condensation, _sccs} = condensation_graph(graph)
      iex> Model.size(condensation)
      3
  """
  @spec condensation_graph(Model.t()) :: {Model.t(), [component()]}
  def condensation_graph(graph) do
    sccs = strongly_connected_components(graph)
    membership = scc_membership(graph)

    # Create condensation graph with SCC indices as nodes
    condensation =
      Enum.reduce(0..(length(sccs) - 1), Model.empty(), fn idx, g ->
        Model.ensure_node(g, idx, "SCC #{idx}")
      end)

    # Add edges between SCCs
    edges = Model.edges(graph)

    condensation =
      Enum.reduce(edges, condensation, fn {from, to, _weight}, g ->
        from_scc = Map.get(membership, from)
        to_scc = Map.get(membership, to)

        # Only add edge if it connects different SCCs
        if from_scc != to_scc and not Model.has_edge?(g, from_scc, to_scc) do
          {:ok, g} = Model.add_edge(g, from_scc, to_scc)
          g
        else
          g
        end
      end)

    {condensation, sccs}
  end

  # Private helper functions for connected components

  defp find_components(_graph, [], _visited, components) do
    Enum.reverse(components)
  end

  defp find_components(graph, [node | rest], visited, components) do
    if node in visited do
      find_components(graph, rest, visited, components)
    else
      # Find all nodes reachable from this node
      component = explore_component(graph, node, MapSet.new())
      new_visited = MapSet.union(visited, MapSet.new(component))
      find_components(graph, rest, new_visited, [component | components])
    end
  end

  defp explore_component(graph, node, visited) do
    if node in visited do
      visited
    else
      visited = MapSet.put(visited, node)

      # Get all neighbors (both incoming and outgoing for undirected)
      {:ok, out_neighbors} = Model.out_neighbors(graph, node)
      {:ok, in_neighbors} = Model.in_neighbors(graph, node)
      neighbors = Map.merge(out_neighbors, in_neighbors) |> Map.keys()

      # Recursively explore neighbors
      visited =
        Enum.reduce(neighbors, visited, fn neighbor, acc ->
          if neighbor in acc do
            acc
          else
            explore_component(graph, neighbor, acc)
          end
        end)

      visited
    end
  end

  # Private helper functions for strongly connected components (Kosaraju's algorithm)

  defp first_dfs(graph, nodes) do
    Enum.reduce(nodes, {MapSet.new(), []}, fn node, {visited, stack} ->
      if node in visited do
        {visited, stack}
      else
        dfs_finish_time(graph, node, visited, stack)
      end
    end)
  end

  defp dfs_finish_time(graph, node, visited, stack) do
    visited = MapSet.put(visited, node)
    {:ok, neighbors} = Model.out_neighbors(graph, node)

    {visited, stack} =
      Enum.reduce(Map.keys(neighbors), {visited, stack}, fn neighbor, {vis, stk} ->
        if neighbor in vis do
          {vis, stk}
        else
          dfs_finish_time(graph, neighbor, vis, stk)
        end
      end)

    # Add node to stack after exploring all descendants
    {visited, [node | stack]}
  end

  defp transpose_graph(graph) do
    nodes = Model.node_ids(graph)
    edges = Model.edges(graph)

    # Create new graph with same nodes
    transposed =
      Enum.reduce(nodes, Model.empty(), fn node, g ->
        {:ok, ctx} = Model.get_node(graph, node)
        Model.ensure_node(g, node, ctx.label)
      end)

    # Add reversed edges
    Enum.reduce(edges, transposed, fn {from, to, weight}, g ->
      {:ok, g} = Model.add_edge(g, to, from, weight)
      g
    end)
  end

  defp find_sccs(_graph, [], _visited, sccs) do
    Enum.reverse(sccs)
  end

  defp find_sccs(graph, [node | rest], visited, sccs) do
    if node in visited do
      find_sccs(graph, rest, visited, sccs)
    else
      # Find SCC starting from this node, passing global visited set
      {scc_nodes, new_visited} = explore_scc(graph, node, visited, [])
      find_sccs(graph, rest, new_visited, [scc_nodes | sccs])
    end
  end

  defp explore_scc(graph, node, global_visited, scc_acc) do
    if node in global_visited do
      {scc_acc, global_visited}
    else
      global_visited = MapSet.put(global_visited, node)
      scc_acc = [node | scc_acc]
      {:ok, neighbors} = Model.out_neighbors(graph, node)

      Enum.reduce(Map.keys(neighbors), {scc_acc, global_visited}, fn neighbor, {acc, vis} ->
        explore_scc(graph, neighbor, vis, acc)
      end)
    end
  end
end
