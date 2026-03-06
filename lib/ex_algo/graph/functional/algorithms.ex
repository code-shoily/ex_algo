defmodule ExAlgo.Graph.Functional.Algorithms do
  @moduledoc """
  Classic graph algorithms implemented purely inductively.

  Each algorithm uses `match/2` as its fundamental step: extracting a node
  from the graph returns both the node's context and the *shrunken* graph
  (all links to/from that node removed). This eliminates the need for
  external visited-sets or mutation — correctness follows from the structure.
  """
  alias ExAlgo.Graph.Functional.Model

  @doc """
  Performs a Topological Sort by repeatedly extracting nodes with 0 in-degree.
  Returns `{:ok, [node_ids]}` or `{:error, :cycle_detected}`.

  Inductive approach: each round, we scan for a node whose `in_edges` map is
  empty in the current (shrunken) graph, extract it with `match/2`, and recurse.
  When an edge is removed by `match/2`, affected neighbours' `in_edges` are
  automatically updated by the inductive model, so the in-degree invariant is
  always up to date without a separate tracking structure.
  """
  def topsort(graph), do: do_topsort(graph, [])

  defp do_topsort(graph, acc) do
    if Model.empty?(graph) do
      {:ok, Enum.reverse(acc)}
    else
      case Enum.find(Model.nodes(graph), fn ctx -> map_size(ctx.in_edges) == 0 end) do
        nil ->
          {:error, :cycle_detected}

        ctx ->
          {:ok, _ctx, remaining_graph} = Model.match(graph, ctx.id)
          do_topsort(remaining_graph, [ctx.id | acc])
      end
    end
  end

  @doc """
  Finds the shortest path between two nodes using Dijkstra's algorithm.
  Returns `{:ok, [node_ids], total_distance}` or `{:error, :no_path}`.

  Edge labels are used as weights (defaults to 1 if `nil`).

  Inductive approach: we maintain a sorted priority queue of `{dist, node, path}`
  entries. Each step extracts the minimum-distance frontier node using `match/2`.
  Because `match/2` removes the node from the graph, we naturally skip
  already-settled nodes — they simply won't be found anymore.
  """
  def shortest_path(graph, start_id, target_id) do
    if start_id == target_id do
      if Model.has_node?(graph, start_id),
        do: {:ok, [start_id], 0},
        else: {:error, :no_path}
    else
      do_dijkstra(graph, [{0, start_id, []}], target_id)
    end
  end

  defp do_dijkstra(_graph, [], _target_id), do: {:error, :no_path}

  defp do_dijkstra(graph, [{dist, current, path} | pq], target_id) do
    case Model.match(graph, current) do
      {:error, :not_found} ->
        do_dijkstra(graph, pq, target_id)

      {:ok, ctx, remaining_graph} ->
        if current == target_id do
          {:ok, Enum.reverse([current | path]), dist}
        else
          new_pq =
            Enum.reduce(ctx.out_edges, pq, fn {neighbor_id, weight}, acc_pq ->
              w = weight || 1
              insert_pq(acc_pq, {dist + w, neighbor_id, [current | path]})
            end)

          do_dijkstra(remaining_graph, new_pq, target_id)
        end
    end
  end

  @doc """
  Finds the Minimum Spanning Tree of the connected component containing the first node.
  Returns `{:ok, [{from, to, weight}]}` or `{:ok, []}` for empty graphs.

  Treats the graph as undirected by extracting both in and out edges from each context.

  Inductive approach (Prim's): start from any node (extracted via `match/2`),
  insert its adjacent edges into a sorted priority queue, then repeatedly
  dequeue the minimum-weight edge whose target is still in the unvisited graph.
  `match/2` is used to extract the target: if it's already been visited,
  `match/2` returns `{:error, :not_found}` and we skip to the next candidate.
  """
  def mst_prim(graph) do
    case Model.node_ids(graph) do
      [] ->
        {:ok, []}

      [start | _] ->
        {:ok, ctx, remaining_graph} = Model.match(graph, start)
        edges = extract_undirected_edges(ctx)
        do_mst_prim(remaining_graph, Enum.sort(edges), [])
    end
  end

  defp do_mst_prim(_graph, [], acc), do: {:ok, Enum.reverse(acc)}

  defp do_mst_prim(graph, [{weight, from, to} | pq], acc) do
    case Model.match(graph, to) do
      {:error, :not_found} ->
        do_mst_prim(graph, pq, acc)

      {:ok, ctx, remaining_graph} ->
        new_acc = [{from, to, weight} | acc]

        new_edges = extract_undirected_edges(ctx)
        new_pq = merge_sorted_lists(pq, Enum.sort(new_edges))

        do_mst_prim(remaining_graph, new_pq, new_acc)
    end
  end

  @doc """
  Finds the Strongly Connected Components (SCCs) of a directed graph.
  Returns a list of lists, where each inner list contains the node IDs of one SCC.

  Uses Kosaraju's two-pass algorithm, adapted for functional inductive graphs:
  1. Pass 1: compute the DFS finishing order of all nodes.
  2. Reverse the graph's edges.
  3. Pass 2: extract components by running DFS on the reversed graph in the compute order.

  Due to the inductive `match/2` operations, nodes visited in one component
  are naturally removed from the graph, preventing them from bleeding into
  subsequent components.
  """
  def scc(%Model{direction: :undirected}) do
    raise ArgumentError, "Strongly Connected Components requires a directed graph"
  end

  def scc(%Model{} = graph) do
    {finishing_order, _shrunken_completely} =
      dfs_finishing_order(graph, Model.node_ids(graph), [])

    reversed_graph = ExAlgo.Graph.Functional.Transform.reverse(graph)
    extract_sccs(reversed_graph, finishing_order, [])
  end

  defp dfs_finishing_order(graph, queue, acc)
  defp dfs_finishing_order(graph, [], acc), do: {acc, graph}

  defp dfs_finishing_order(graph, [current | queue], acc) do
    case Model.match(graph, current) do
      {:error, :not_found} ->
        dfs_finishing_order(graph, queue, acc)

      {:ok, ctx, remaining_graph} ->
        children = Map.keys(ctx.out_edges)

        {new_acc, graph_after_children} =
          dfs_finishing_order(remaining_graph, children, acc)

        dfs_finishing_order(graph_after_children, queue, [current | new_acc])
    end
  end

  defp extract_sccs(_graph, [], acc), do: Enum.reverse(acc)

  defp extract_sccs(graph, [current | rest], acc) do
    case Model.match(graph, current) do
      {:error, :not_found} ->
        extract_sccs(graph, rest, acc)

      {:ok, _ctx, _remaining} ->
        {component_ids, remainder} = extract_component(graph, [current], [])
        extract_sccs(remainder, rest, [component_ids | acc])
    end
  end

  defp extract_component(graph, [], acc), do: {Enum.reverse(acc), graph}

  defp extract_component(graph, [current | stack], acc) do
    case Model.match(graph, current) do
      {:error, :not_found} ->
        extract_component(graph, stack, acc)

      {:ok, ctx, remaining_graph} ->
        neighbors = Map.keys(ctx.out_edges)
        new_stack = neighbors ++ stack
        extract_component(remaining_graph, new_stack, [current | acc])
    end
  end

  defp insert_pq([], item), do: [item]
  defp insert_pq([{d, _, _} = h | t], {new_d, _, _} = item) when new_d <= d, do: [item, h | t]
  defp insert_pq([h | t], item), do: [h | insert_pq(t, item)]

  defp extract_undirected_edges(ctx) do
    out_e = Enum.map(ctx.out_edges, fn {to, w} -> {w || 1, ctx.id, to} end)
    in_e = Enum.map(ctx.in_edges, fn {from, w} -> {w || 1, ctx.id, from} end)
    out_e ++ in_e
  end

  defp merge_sorted_lists(list1, list2), do: :lists.merge(list1, list2)
end
