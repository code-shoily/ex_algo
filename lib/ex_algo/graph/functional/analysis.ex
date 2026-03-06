defmodule ExAlgo.Graph.Functional.Analysis do
  @moduledoc """
  High-level graph analysis for inductive graphs.
  Focuses on connectivity, structural vulnerabilities, and components.
  """
  alias ExAlgo.Graph.Functional.Model

  @type bridge :: {Model.node_id(), Model.node_id()}

  @doc """
  Finds all connected components in an undirected graph.
  Returns a list of lists of node IDs.
  """
  @spec connected_components(Model.t()) :: [[Model.node_id()]]
  def connected_components(graph) do
    do_find_components(graph, [])
  end

  defp do_find_components(graph, acc) do
    if Model.empty?(graph) do
      Enum.reverse(acc)
    else
      [start_id | _] = Model.node_ids(graph)

      {component, remaining_graph} = extract_component(graph, [start_id], [])
      do_find_components(remaining_graph, [component | acc])
    end
  end

  @doc """
  Identifies bridges (cut-edges) and articulation points (cut-vertices)
  in an undirected graph using a single-pass DFS.
  """
  @spec analyze_connectivity(Model.t()) ::
          %{bridges: [bridge()], points: [Model.node_id()]}
  def analyze_connectivity(graph) do
    initial_state = %{
      tin: %{},
      low: %{},
      timer: 0,
      bridges: [],
      points: MapSet.new(),
      visited: MapSet.new()
    }

    final_state =
      Enum.reduce(Model.node_ids(graph), initial_state, fn id, acc ->
        if MapSet.member?(acc.visited, id) do
          acc
        else
          tarjan_dfs(graph, id, nil, acc) |> elem(0)
        end
      end)

    %{bridges: final_state.bridges, points: MapSet.to_list(final_state.points)}
  end

  defp tarjan_dfs(graph, v, parent, state) do
    tin = Map.put(state.tin, v, state.timer)
    low = Map.put(state.low, v, state.timer)
    visited = MapSet.put(state.visited, v)
    timer = state.timer + 1

    state = %{state | tin: tin, low: low, visited: visited, timer: timer}

    {:ok, ctx} = Model.get_node(graph, v)
    neighbors = Map.keys(ctx.out_edges)

    {final_state, children_count} =
      Enum.reduce(neighbors, {state, 0}, fn to, {acc_state, children} ->
        cond do
          to == parent ->
            {acc_state, children}

          MapSet.member?(acc_state.visited, to) ->
            new_low = min(acc_state.low[v], acc_state.tin[to])
            {%{acc_state | low: Map.put(acc_state.low, v, new_low)}, children}

          true ->
            {post_dfs_state, _} = tarjan_dfs(graph, to, v, acc_state)

            new_v_low = min(post_dfs_state.low[v], post_dfs_state.low[to])

            new_bridges =
              if post_dfs_state.low[to] > post_dfs_state.tin[v] do
                [{min(v, to), max(v, to)} | post_dfs_state.bridges]
              else
                post_dfs_state.bridges
              end

            new_points =
              if parent != nil and post_dfs_state.low[to] >= post_dfs_state.tin[v] do
                MapSet.put(post_dfs_state.points, v)
              else
                post_dfs_state.points
              end

            {%{
               post_dfs_state
               | low: Map.put(post_dfs_state.low, v, new_v_low),
                 bridges: new_bridges,
                 points: new_points
             }, children + 1}
        end
      end)

    final_state =
      if parent == nil and children_count > 1 do
        %{final_state | points: MapSet.put(final_state.points, v)}
      else
        final_state
      end

    {final_state, children_count}
  end

  defp extract_component(graph, [], acc), do: {acc, graph}

  defp extract_component(graph, [id | stack], acc) do
    case Model.match(graph, id) do
      {:error, :not_found} ->
        extract_component(graph, stack, acc)

      {:ok, ctx, remaining} ->
        neighbors = Map.keys(ctx.out_edges)
        extract_component(remaining, neighbors ++ stack, [id | acc])
    end
  end
end
