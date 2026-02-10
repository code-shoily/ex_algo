defmodule ExAlgo.Graph.Functional.Pathfinding do
  @moduledoc """
  Shortest path algorithms for functional graphs.

  This module provides various shortest path algorithms including:
  - Dijkstra's algorithm for non-negative weighted graphs
  - A* algorithm with heuristic functions
  - Bellman-Ford algorithm for graphs with negative weights

  ## Performance

  Dijkstra and A* use a priority queue backed by `ExAlgo.Heap.PairingHeap`,
  which provides excellent amortized performance:
  - Insert: O(1)
  - Find-min: O(1)
  - Delete-min: O(log n)

  This makes the algorithms efficient even on large graphs.
  """

  alias ExAlgo.Graph.Functional.Model
  alias __MODULE__.PriorityQueue

  @type node_id :: Model.node_id()
  @type weight :: number()
  @type path :: [node_id()]
  @type distance :: number()
  @type heuristic :: (node_id() -> number())

  @doc """
  Finds the shortest path using Dijkstra's algorithm.

  This algorithm works on graphs with non-negative edge weights. The edge labels
  are used as weights. If an edge has no label (nil), it's treated as weight 0.

  Returns `{:ok, {path, distance}}` where path is the list of nodes from start to goal
  and distance is the total path cost, or `{:error, reason}` if no path exists.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2, 5); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3, 3); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 3, 10); g end)
      iex> dijkstra(graph, 1, 3)
      {:ok, {[1, 2, 3], 8}}
  """
  @spec dijkstra(Model.t(), node_id(), node_id()) ::
          {:ok, {path(), distance()}} | {:error, :not_found | :unreachable}
  def dijkstra(graph, start, goal) do
    cond do
      not Model.has_node?(graph, start) -> {:error, :not_found}
      not Model.has_node?(graph, goal) -> {:error, :not_found}
      start == goal -> {:ok, {[start], 0}}
      true -> dijkstra_search(graph, start, goal)
    end
  end

  @doc """
  Finds shortest paths from a source node to all other nodes using Dijkstra's algorithm.

  Returns `{:ok, distances, predecessors}` where:
  - distances is a map of `%{node_id => distance_from_start}`
  - predecessors is a map of `%{node_id => previous_node_in_path}`

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2, 5); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3, 3); g end)
      iex> {:ok, distances, _predecessors} = dijkstra_all(graph, 1)
      iex> distances[3]
      8
  """
  @spec dijkstra_all(Model.t(), node_id()) ::
          {:ok, %{node_id() => distance()}, %{node_id() => node_id()}} | {:error, :not_found}
  def dijkstra_all(graph, start) do
    if Model.has_node?(graph, start) do
      {distances, predecessors} = dijkstra_all_paths(graph, start)
      {:ok, distances, predecessors}
    else
      {:error, :not_found}
    end
  end

  @doc """
  Finds the shortest path using A* algorithm with a heuristic function.

  The heuristic function should estimate the distance from any node to the goal.
  For A* to find the optimal path, the heuristic must be admissible (never overestimate).

  Returns `{:ok, {path, distance}}` or `{:error, reason}`.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2, 5); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3, 3); g end)
      iex> heuristic = fn _node -> 0 end  # Dijkstra when heuristic is 0
      iex> astar(graph, 1, 3, heuristic)
      {:ok, {[1, 2, 3], 8}}
  """
  @spec astar(Model.t(), node_id(), node_id(), heuristic()) ::
          {:ok, {path(), distance()}} | {:error, :not_found | :unreachable}
  def astar(graph, start, goal, heuristic_fn) do
    cond do
      not Model.has_node?(graph, start) -> {:error, :not_found}
      not Model.has_node?(graph, goal) -> {:error, :not_found}
      start == goal -> {:ok, {[start], 0}}
      true -> astar_search(graph, start, goal, heuristic_fn)
    end
  end

  @doc """
  Finds the shortest path using Bellman-Ford algorithm.

  This algorithm can handle negative edge weights and will detect negative cycles.
  Slower than Dijkstra (O(V*E) vs O(E log V)) but more general.

  Returns `{:ok, {path, distance}}`, `{:error, :unreachable}` if no path exists,
  or `{:error, :negative_cycle}` if a negative cycle is detected.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2, 5); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3, -2); g end)
      iex> bellman_ford(graph, 1, 3)
      {:ok, {[1, 2, 3], 3}}
  """
  @spec bellman_ford(Model.t(), node_id(), node_id()) ::
          {:ok, {path(), distance()}} | {:error, :not_found | :unreachable | :negative_cycle}
  def bellman_ford(graph, start, goal) do
    cond do
      not Model.has_node?(graph, start) -> {:error, :not_found}
      not Model.has_node?(graph, goal) -> {:error, :not_found}
      start == goal -> {:ok, {[start], 0}}
      true -> bellman_ford_search(graph, start, goal)
    end
  end

  @doc """
  Finds shortest paths from a source to all nodes using Bellman-Ford algorithm.

  Returns `{:ok, distances, predecessors}` or `{:error, :negative_cycle}`.
  """
  @spec bellman_ford_all(Model.t(), node_id()) ::
          {:ok, %{node_id() => distance()}, %{node_id() => node_id()}}
          | {:error, :not_found | :negative_cycle}
  def bellman_ford_all(graph, start) do
    if Model.has_node?(graph, start) do
      bellman_ford_all_paths(graph, start)
    else
      {:error, :not_found}
    end
  end

  # Private helper functions for Dijkstra

  defp dijkstra_search(graph, start, goal) do
    {distances, predecessors} = dijkstra_all_paths(graph, start)

    case Map.fetch(distances, goal) do
      {:ok, distance} when distance != :infinity ->
        path = reconstruct_path(predecessors, start, goal)
        {:ok, {path, distance}}

      _ ->
        {:error, :unreachable}
    end
  end

  defp dijkstra_all_paths(graph, start) do
    # Initialize distances and priority queue
    distances = %{start => 0}
    predecessors = %{}
    pq = PriorityQueue.new() |> PriorityQueue.push(start, 0)
    visited = MapSet.new()

    dijkstra_loop(graph, pq, distances, predecessors, visited)
  end

  defp dijkstra_loop(graph, pq, distances, predecessors, visited) do
    case PriorityQueue.pop(pq) do
      {{:value, current, _priority}, rest_pq} ->
        if current in visited do
          dijkstra_loop(graph, rest_pq, distances, predecessors, visited)
        else
          visited = MapSet.put(visited, current)
          current_dist = Map.get(distances, current, :infinity)

          {:ok, neighbors} = Model.out_neighbors(graph, current)

          {new_pq, new_distances, new_predecessors} =
            Enum.reduce(neighbors, {rest_pq, distances, predecessors}, fn {neighbor, weight},
                                                                           {pq_acc, dist_acc,
                                                                            pred_acc} ->
              edge_weight = weight || 0
              new_distance = add_distance(current_dist, edge_weight)
              old_distance = Map.get(dist_acc, neighbor, :infinity)

              if compare_distance(new_distance, old_distance) == :lt do
                {
                  PriorityQueue.push(pq_acc, neighbor, new_distance),
                  Map.put(dist_acc, neighbor, new_distance),
                  Map.put(pred_acc, neighbor, current)
                }
              else
                {pq_acc, dist_acc, pred_acc}
              end
            end)

          dijkstra_loop(graph, new_pq, new_distances, new_predecessors, visited)
        end

      {:empty, _} ->
        {distances, predecessors}
    end
  end

  # Private helper functions for A*

  defp astar_search(graph, start, goal, heuristic_fn) do
    g_scores = %{start => 0}
    f_scores = %{start => heuristic_fn.(start)}
    predecessors = %{}
    open_set = PriorityQueue.new() |> PriorityQueue.push(start, f_scores[start])
    closed_set = MapSet.new()

    astar_loop(graph, goal, heuristic_fn, open_set, closed_set, g_scores, f_scores, predecessors)
  end

  defp astar_loop(graph, goal, heuristic_fn, open_set, closed_set, g_scores, f_scores, predecessors) do
    case PriorityQueue.pop(open_set) do
      {{:value, current, _priority}, rest_open} ->
        cond do
          current == goal ->
            path = reconstruct_path(predecessors, Map.keys(g_scores) |> hd(), goal)
            distance = Map.get(g_scores, goal)
            {:ok, {path, distance}}

          current in closed_set ->
            astar_loop(graph, goal, heuristic_fn, rest_open, closed_set, g_scores, f_scores, predecessors)

          true ->
            closed_set = MapSet.put(closed_set, current)
            current_g = Map.get(g_scores, current, :infinity)

            {:ok, neighbors} = Model.out_neighbors(graph, current)

            {new_open, new_g, new_f, new_pred} =
              Enum.reduce(neighbors, {rest_open, g_scores, f_scores, predecessors}, fn {neighbor, weight},
                                                                                        {open_acc, g_acc, f_acc,
                                                                                         pred_acc} ->
                if neighbor in closed_set do
                  {open_acc, g_acc, f_acc, pred_acc}
                else
                  edge_weight = weight || 0
                  tentative_g = add_distance(current_g, edge_weight)
                  old_g = Map.get(g_acc, neighbor, :infinity)

                  if compare_distance(tentative_g, old_g) == :lt do
                    new_f_score = add_distance(tentative_g, heuristic_fn.(neighbor))

                    {
                      PriorityQueue.push(open_acc, neighbor, new_f_score),
                      Map.put(g_acc, neighbor, tentative_g),
                      Map.put(f_acc, neighbor, new_f_score),
                      Map.put(pred_acc, neighbor, current)
                    }
                  else
                    {open_acc, g_acc, f_acc, pred_acc}
                  end
                end
              end)

            astar_loop(graph, goal, heuristic_fn, new_open, closed_set, new_g, new_f, new_pred)
        end

      {:empty, _} ->
        {:error, :unreachable}
    end
  end

  # Private helper functions for Bellman-Ford

  defp bellman_ford_search(graph, start, goal) do
    case bellman_ford_all_paths(graph, start) do
      {:ok, distances, predecessors} ->
        case Map.fetch(distances, goal) do
          {:ok, distance} when distance != :infinity ->
            path = reconstruct_path(predecessors, start, goal)
            {:ok, {path, distance}}

          _ ->
            {:error, :unreachable}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp bellman_ford_all_paths(graph, start) do
    nodes = Model.node_ids(graph)
    edges = Model.edges(graph)

    # Initialize distances
    distances =
      Enum.reduce(nodes, %{}, fn node, acc ->
        Map.put(acc, node, if(node == start, do: 0, else: :infinity))
      end)

    predecessors = %{}

    # Relax edges V-1 times
    {final_distances, final_predecessors} =
      Enum.reduce(1..(length(nodes) - 1), {distances, predecessors}, fn _i, {dist_acc, pred_acc} ->
        relax_all_edges(edges, dist_acc, pred_acc)
      end)

    # Check for negative cycles
    {distances_check, _} = relax_all_edges(edges, final_distances, final_predecessors)

    if distances_check != final_distances do
      {:error, :negative_cycle}
    else
      {:ok, final_distances, final_predecessors}
    end
  end

  defp relax_all_edges(edges, distances, predecessors) do
    Enum.reduce(edges, {distances, predecessors}, fn {from, to, weight}, {dist_acc, pred_acc} ->
      from_dist = Map.get(dist_acc, from, :infinity)
      to_dist = Map.get(dist_acc, to, :infinity)
      edge_weight = weight || 0

      new_dist = add_distance(from_dist, edge_weight)

      if from_dist != :infinity and compare_distance(new_dist, to_dist) == :lt do
        {
          Map.put(dist_acc, to, new_dist),
          Map.put(pred_acc, to, from)
        }
      else
        {dist_acc, pred_acc}
      end
    end)
  end

  # Utility functions

  defp reconstruct_path(predecessors, start, goal) do
    reconstruct_path_helper(predecessors, start, goal, [goal])
  end

  defp reconstruct_path_helper(predecessors, start, current, path) do
    if current == start do
      path
    else
      case Map.fetch(predecessors, current) do
        {:ok, prev} -> reconstruct_path_helper(predecessors, start, prev, [prev | path])
        :error -> path
      end
    end
  end

  defp add_distance(:infinity, _), do: :infinity
  defp add_distance(_, :infinity), do: :infinity
  defp add_distance(a, b), do: a + b

  defp compare_distance(:infinity, :infinity), do: :eq
  defp compare_distance(:infinity, _), do: :gt
  defp compare_distance(_, :infinity), do: :lt
  defp compare_distance(a, b) when a < b, do: :lt
  defp compare_distance(a, b) when a > b, do: :gt
  defp compare_distance(_, _), do: :eq

  # Priority queue implementation using PairingHeap
  #
  # PairingHeap provides excellent performance characteristics:
  # - insert: O(1) amortized
  # - find_min: O(1)
  # - delete_min: O(log n) amortized
  #
  # This makes it ideal for Dijkstra and A* which perform many insertions
  # and extract-min operations.
  defmodule PriorityQueue do
    @moduledoc false

    alias ExAlgo.Heap.PairingHeap

    defstruct heap: nil

    def new, do: %__MODULE__{heap: PairingHeap.new()}

    def push(%__MODULE__{heap: heap}, item, priority) do
      new_heap = PairingHeap.insert(heap, {priority, item})
      %__MODULE__{heap: new_heap}
    end

    def pop(%__MODULE__{heap: heap}) do
      case PairingHeap.find_min(heap) do
        {:ok, {priority, item}} ->
          {:ok, new_heap} = PairingHeap.delete_min(heap)
          {{:value, item, priority}, %__MODULE__{heap: new_heap}}

        {:error, :empty} ->
          {:empty, %__MODULE__{heap: heap}}
      end
    end
  end
end
