defmodule ExAlgo.Graph.Functional.Properties do
  @moduledoc """
  Graph property checking and analysis algorithms.

  This module provides algorithms for checking various graph properties:
  - Cycle detection (directed and undirected graphs)
  - Bipartite testing and partitioning
  - DAG (Directed Acyclic Graph) detection
  - Tree validation
  """

  alias ExAlgo.Graph.Functional.Model

  @type node_id :: Model.node_id()
  @type color :: :red | :blue
  @type partition :: {[node_id()], [node_id()]}

  @doc """
  Checks if the graph contains a cycle.

  For directed graphs, detects directed cycles.
  For undirected graphs (or treating directed as undirected), detects any cycle.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      iex> has_cycle?(graph)
      false

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 3, 1); g end)
      iex> has_cycle?(graph)
      true
  """
  @spec has_cycle?(Model.t()) :: boolean()
  def has_cycle?(graph) do
    has_cycle_directed?(graph)
  end

  @doc """
  Checks if the directed graph contains a directed cycle.

  Uses DFS with three colors: white (unvisited), gray (in progress), black (done).
  A back edge to a gray node indicates a cycle.

  ## Complexity
  - Time: O(V + E)
  - Space: O(V)
  """
  @spec has_cycle_directed?(Model.t()) :: boolean()
  def has_cycle_directed?(graph) do
    nodes = Model.node_ids(graph)
    colors = Map.new(nodes, fn node -> {node, :white} end)

    Enum.reduce_while(nodes, colors, fn node, color_map ->
      case color_map[node] do
        :white ->
          case dfs_cycle_check(graph, node, color_map) do
            {:cycle, _} -> {:halt, :has_cycle}
            {:ok, new_colors} -> {:cont, new_colors}
          end

        _ ->
          {:cont, color_map}
      end
    end) == :has_cycle
  end

  @doc """
  Checks if the graph contains a cycle when treating it as undirected.

  Uses DFS to detect back edges (ignoring parent to avoid false positives).

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 1); g end)
      iex> has_cycle_undirected?(graph)
      false
  """
  @spec has_cycle_undirected?(Model.t()) :: boolean()
  def has_cycle_undirected?(graph) do
    nodes = Model.node_ids(graph)
    visited = MapSet.new()

    Enum.reduce_while(nodes, visited, fn node, vis ->
      if node in vis do
        {:cont, vis}
      else
        case dfs_undirected_cycle(graph, node, nil, vis) do
          {:cycle, _} -> {:halt, :has_cycle}
          {:ok, new_visited} -> {:cont, new_visited}
        end
      end
    end) == :has_cycle
  end

  @doc """
  Checks if the graph is bipartite (2-colorable).

  A graph is bipartite if its vertices can be divided into two disjoint sets
  such that every edge connects vertices from different sets.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> Model.ensure_node(4)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 3, 4); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 4, 1); g end)
      iex> is_bipartite?(graph)
      true
  """
  @spec is_bipartite?(Model.t()) :: boolean()
  def is_bipartite?(graph) do
    case bipartite_partition(graph) do
      {:ok, _partition} -> true
      {:error, :not_bipartite} -> false
    end
  end

  @doc """
  Attempts to partition the graph into two bipartite sets.

  Returns `{:ok, {set1, set2}}` if the graph is bipartite, where set1 and set2
  are lists of node IDs. Returns `{:error, :not_bipartite}` otherwise.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      iex> {:ok, {set1, set2}} = bipartite_partition(graph)
      iex> 1 in set1 and 3 in set1 and 2 in set2
      true
  """
  @spec bipartite_partition(Model.t()) :: {:ok, partition()} | {:error, :not_bipartite}
  def bipartite_partition(graph) do
    nodes = Model.node_ids(graph)

    case try_bipartite_coloring(graph, nodes, %{}) do
      {:ok, coloring} ->
        {red, blue} =
          Enum.split_with(Map.to_list(coloring), fn {_node, color} ->
            color == :red
          end)

        {:ok, {Enum.map(red, fn {n, _} -> n end), Enum.map(blue, fn {n, _} -> n end)}}

      {:error, :not_bipartite} ->
        {:error, :not_bipartite}
    end
  end

  @doc """
  Checks if the directed graph is a DAG (Directed Acyclic Graph).

  A DAG has no directed cycles. This is equivalent to checking if a
  topological ordering exists.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      iex> is_dag?(graph)
      true

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 1); g end)
      iex> is_dag?(graph)
      false
  """
  @spec is_dag?(Model.t()) :: boolean()
  def is_dag?(graph) do
    not has_cycle_directed?(graph)
  end

  @doc """
  Checks if the graph is a tree.

  A tree is a connected, acyclic graph. For undirected graphs, this means:
  1. Connected (one component)
  2. No cycles
  3. Has exactly V-1 edges (where V is number of vertices)

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      iex> is_tree?(graph)
      false
  """
  @spec is_tree?(Model.t()) :: boolean()
  def is_tree?(graph) do
    nodes = Model.node_ids(graph)
    num_nodes = length(nodes)

    cond do
      num_nodes == 0 -> true
      num_nodes == 1 -> true
      true ->
        # Count unique undirected edges
        edges = get_undirected_edge_count(graph)

        # Tree must have exactly n-1 edges
        edges == num_nodes - 1 and
          is_connected(graph) and
          not has_cycle_undirected?(graph)
    end
  end

  @doc """
  Checks if the graph is connected.

  For directed graphs, checks weak connectivity (treating edges as undirected).
  """
  @spec is_connected?(Model.t()) :: boolean()
  def is_connected?(graph) do
    is_connected(graph)
  end

  @doc """
  Returns the number of edges in the graph.

  For directed graphs, counts directed edges.
  """
  @spec edge_count(Model.t()) :: non_neg_integer()
  def edge_count(graph) do
    Model.edges(graph) |> length()
  end

  @doc """
  Returns the number of nodes in the graph.
  """
  @spec node_count(Model.t()) :: non_neg_integer()
  def node_count(graph) do
    Model.node_ids(graph) |> length()
  end

  @doc """
  Checks if the graph has an Eulerian circuit.

  An Eulerian circuit is a path that visits every edge exactly once and
  returns to the starting vertex. For undirected graphs, this exists if:
  - The graph is connected (ignoring isolated vertices)
  - Every vertex has even degree

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 1); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 3, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 3, 1); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 3); g end)
      iex> has_eulerian_circuit?(graph)
      true
  """
  @spec has_eulerian_circuit?(Model.t()) :: boolean()
  def has_eulerian_circuit?(graph) do
    nodes_with_edges = get_nodes_with_edges(graph)

    case nodes_with_edges do
      [] ->
        true

      [start | _] ->
        # Check if all nodes with edges are connected
        if not all_connected?(graph, nodes_with_edges, start) do
          false
        else
          # Check if all nodes have even degree
          Enum.all?(nodes_with_edges, fn node ->
            degree = get_undirected_degree(graph, node)
            rem(degree, 2) == 0
          end)
        end
    end
  end

  @doc """
  Checks if the graph has an Eulerian path.

  An Eulerian path is a path that visits every edge exactly once.
  For undirected graphs, this exists if:
  - The graph is connected (ignoring isolated vertices)
  - Exactly 0 or 2 vertices have odd degree

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 1); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 3, 2); g end)
      iex> has_eulerian_path?(graph)
      true
  """
  @spec has_eulerian_path?(Model.t()) :: boolean()
  def has_eulerian_path?(graph) do
    nodes_with_edges = get_nodes_with_edges(graph)

    case nodes_with_edges do
      [] ->
        true

      [start | _] ->
        # Check if all nodes with edges are connected
        if not all_connected?(graph, nodes_with_edges, start) do
          false
        else
          # Count nodes with odd degree
          odd_degree_count =
            Enum.count(nodes_with_edges, fn node ->
              degree = get_undirected_degree(graph, node)
              rem(degree, 2) == 1
            end)

          # Eulerian path exists if exactly 0 or 2 vertices have odd degree
          odd_degree_count == 0 or odd_degree_count == 2
        end
    end
  end

  @doc """
  Finds an Eulerian circuit in the graph if one exists.

  Returns `{:ok, path}` where path is a list of node IDs representing the circuit,
  or `{:error, :no_eulerian_circuit}` if no circuit exists.

  Uses Hierholzer's algorithm.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 1); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 3, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 3, 1); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 3); g end)
      iex> {:ok, path} = find_eulerian_circuit(graph)
      iex> length(path)
      4
  """
  @spec find_eulerian_circuit(Model.t()) :: {:ok, [node_id()]} | {:error, :no_eulerian_circuit}
  def find_eulerian_circuit(graph) do
    if not has_eulerian_circuit?(graph) do
      {:error, :no_eulerian_circuit}
    else
      nodes_with_edges = get_nodes_with_edges(graph)

      case nodes_with_edges do
        [] ->
          {:ok, []}

        [start | _] ->
          # Use Hierholzer's algorithm
          path = hierholzer(graph, start)
          {:ok, path}
      end
    end
  end

  @doc """
  Finds an Eulerian path in the graph if one exists.

  Returns `{:ok, path}` where path is a list of node IDs representing the path,
  or `{:error, :no_eulerian_path}` if no path exists.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 1); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 3, 2); g end)
      iex> {:ok, path} = find_eulerian_path(graph)
      iex> length(path)
      3
  """
  @spec find_eulerian_path(Model.t()) :: {:ok, [node_id()]} | {:error, :no_eulerian_path}
  def find_eulerian_path(graph) do
    if not has_eulerian_path?(graph) do
      {:error, :no_eulerian_path}
    else
      nodes_with_edges = get_nodes_with_edges(graph)

      case nodes_with_edges do
        [] ->
          {:ok, []}

        _ ->
          # Find starting node (node with odd degree, or any node if all even)
          start =
            Enum.find(nodes_with_edges, hd(nodes_with_edges), fn node ->
              degree = get_undirected_degree(graph, node)
              rem(degree, 2) == 1
            end)

          # Use Hierholzer's algorithm
          path = hierholzer(graph, start)
          {:ok, path}
      end
    end
  end

  # Private helper functions

  # DFS for directed cycle detection (using three colors)
  defp dfs_cycle_check(graph, node, colors) do
    colors = Map.put(colors, node, :gray)
    {:ok, neighbors} = Model.out_neighbors(graph, node)

    result =
      Enum.reduce_while(Map.keys(neighbors), {:ok, colors}, fn neighbor, {:ok, color_map} ->
        case color_map[neighbor] do
          :white ->
            case dfs_cycle_check(graph, neighbor, color_map) do
              {:cycle, _} = result -> {:halt, result}
              {:ok, new_colors} -> {:cont, {:ok, new_colors}}
            end

          :gray ->
            # Back edge - cycle detected!
            {:halt, {:cycle, color_map}}

          :black ->
            # Cross or forward edge - no cycle
            {:cont, {:ok, color_map}}
        end
      end)

    case result do
      {:cycle, _} = cycle -> cycle
      {:ok, final_colors} -> {:ok, Map.put(final_colors, node, :black)}
    end
  end

  # DFS for undirected cycle detection
  defp dfs_undirected_cycle(graph, node, parent, visited) do
    visited = MapSet.put(visited, node)

    # Get all neighbors (treat as undirected)
    {:ok, out_neighbors} = Model.out_neighbors(graph, node)
    {:ok, in_neighbors} = Model.in_neighbors(graph, node)
    neighbors = Map.merge(out_neighbors, in_neighbors) |> Map.keys()

    Enum.reduce_while(neighbors, {:ok, visited}, fn neighbor, {:ok, vis} ->
      cond do
        neighbor == parent ->
          # Ignore parent edge
          {:cont, {:ok, vis}}

        neighbor in vis ->
          # Back edge - cycle detected!
          {:halt, {:cycle, vis}}

        true ->
          case dfs_undirected_cycle(graph, neighbor, node, vis) do
            {:cycle, _} = result -> {:halt, result}
            {:ok, new_visited} -> {:cont, {:ok, new_visited}}
          end
      end
    end)
  end

  # BFS for bipartite coloring
  defp try_bipartite_coloring(_graph, [], coloring), do: {:ok, coloring}

  defp try_bipartite_coloring(graph, [node | rest], coloring) do
    if Map.has_key?(coloring, node) do
      try_bipartite_coloring(graph, rest, coloring)
    else
      case bfs_bipartite(graph, node, :red, coloring) do
        {:ok, new_coloring} -> try_bipartite_coloring(graph, rest, new_coloring)
        {:error, :not_bipartite} -> {:error, :not_bipartite}
      end
    end
  end

  defp bfs_bipartite(graph, start, start_color, coloring) do
    queue = :queue.from_list([{start, start_color}])
    coloring = Map.put(coloring, start, start_color)

    bfs_bipartite_loop(graph, queue, coloring)
  end

  defp bfs_bipartite_loop(graph, queue, coloring) do
    case :queue.out(queue) do
      {{:value, {node, color}}, rest_queue} ->
        opposite_color = opposite_color(color)

        # Get all neighbors (treat as undirected)
        {:ok, out_neighbors} = Model.out_neighbors(graph, node)
        {:ok, in_neighbors} = Model.in_neighbors(graph, node)
        neighbors = Map.merge(out_neighbors, in_neighbors) |> Map.keys()

        result =
          Enum.reduce_while(neighbors, {:ok, rest_queue, coloring}, fn neighbor,
                                                                        {:ok, q, col} ->
            case Map.get(col, neighbor) do
              nil ->
                # Uncolored - color it opposite
                new_col = Map.put(col, neighbor, opposite_color)
                new_q = :queue.in({neighbor, opposite_color}, q)
                {:cont, {:ok, new_q, new_col}}

              ^color ->
                # Same color as current - not bipartite!
                {:halt, {:error, :not_bipartite}}

              _ ->
                # Different color - good
                {:cont, {:ok, q, col}}
            end
          end)

        case result do
          {:error, :not_bipartite} -> {:error, :not_bipartite}
          {:ok, new_queue, new_coloring} -> bfs_bipartite_loop(graph, new_queue, new_coloring)
        end

      {:empty, _} ->
        {:ok, coloring}
    end
  end

  defp opposite_color(:red), do: :blue
  defp opposite_color(:blue), do: :red

  # Check connectivity
  defp is_connected(graph) do
    nodes = Model.node_ids(graph)

    case nodes do
      [] -> true
      [start | _] ->
        visited = bfs_connected(graph, start, MapSet.new())
        MapSet.size(visited) == length(nodes)
    end
  end

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

  # Count undirected edges (avoid double-counting)
  defp get_undirected_edge_count(graph) do
    edges = Model.edges(graph)

    # Count unique undirected edges
    unique_edges =
      Enum.reduce(edges, MapSet.new(), fn {from, to, _weight}, acc ->
        # Normalize edge direction for undirected graph
        edge =
          if compare_nodes(from, to) == :lt do
            {from, to}
          else
            {to, from}
          end

        MapSet.put(acc, edge)
      end)

    MapSet.size(unique_edges)
  end

  defp compare_nodes(a, b) when a < b, do: :lt
  defp compare_nodes(a, b) when a > b, do: :gt
  defp compare_nodes(_, _), do: :eq

  # Eulerian path/circuit helpers

  defp get_nodes_with_edges(graph) do
    Model.node_ids(graph)
    |> Enum.filter(fn node ->
      {:ok, out_neighbors} = Model.out_neighbors(graph, node)
      {:ok, in_neighbors} = Model.in_neighbors(graph, node)
      not (Enum.empty?(out_neighbors) and Enum.empty?(in_neighbors))
    end)
  end

  defp all_connected?(graph, nodes, start) do
    visited = bfs_connected(graph, start, MapSet.new())
    Enum.all?(nodes, fn node -> node in visited end)
  end

  defp get_undirected_degree(graph, node) do
    {:ok, out_neighbors} = Model.out_neighbors(graph, node)
    {:ok, in_neighbors} = Model.in_neighbors(graph, node)

    # For undirected graph, count unique neighbors
    all_neighbors = Map.merge(out_neighbors, in_neighbors) |> Map.keys() |> MapSet.new()
    MapSet.size(all_neighbors)
  end

  # Hierholzer's algorithm for finding Eulerian path/circuit
  defp hierholzer(graph, start) do
    # Build adjacency list (mutable for edge removal during traversal)
    adj_list = build_adjacency_list(graph)

    # Find circuit using DFS
    {circuit, _} = hierholzer_dfs(start, adj_list, [])

    circuit
  end

  defp build_adjacency_list(graph) do
    nodes = Model.node_ids(graph)

    Enum.reduce(nodes, %{}, fn node, acc ->
      {:ok, out_neighbors} = Model.out_neighbors(graph, node)
      {:ok, in_neighbors} = Model.in_neighbors(graph, node)

      # Combine neighbors (treat as undirected)
      neighbors = Map.merge(out_neighbors, in_neighbors) |> Map.keys()

      Map.put(acc, node, neighbors)
    end)
  end

  defp hierholzer_dfs(current, adj_list, circuit) do
    case Map.get(adj_list, current, []) do
      [] ->
        # No more edges from current node, add to circuit
        {[current | circuit], adj_list}

      [next | rest] ->
        # Remove edge current -> next and next -> current
        adj_list = Map.put(adj_list, current, rest)

        adj_list =
          Map.update(adj_list, next, [], fn neighbors ->
            List.delete(neighbors, current)
          end)

        # Recursively visit next
        {circuit, adj_list} = hierholzer_dfs(next, adj_list, circuit)

        # After exhausting path from next, try other edges from current
        hierholzer_dfs(current, adj_list, circuit)
    end
  end
end
