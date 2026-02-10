defmodule ExAlgo.Graph.Functional.Traversal do
  @moduledoc """
  Graph traversal algorithms for functional graphs.

  This module provides depth-first search (DFS), breadth-first search (BFS),
  and related traversal operations.
  """

  alias ExAlgo.Graph.Functional.Model
  alias ExAlgo.Graph.Functional.Model.Context

  @type node_id :: Model.node_id()
  @type visit_result :: :continue | :halt | {:halt, any()}

  @doc """
  Performs a depth-first search traversal starting from a given node.

  Returns a list of node IDs in the order they were visited.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 3); g end)
      iex> dfs(graph, 1)
      {:ok, [1, 2, 3]}
  """
  @spec dfs(Model.t(), node_id()) :: {:ok, [node_id()]} | {:error, :not_found}
  def dfs(graph, start) do
    if Model.has_node?(graph, start) do
      {_visited_set, result} = dfs_recursive(graph, start, MapSet.new(), [])
      {:ok, Enum.reverse(result)}
    else
      {:error, :not_found}
    end
  end

  @doc """
  Performs a depth-first search with a visitor function.

  The visitor function receives each node's context and can return:
  - `:continue` - Continue traversal
  - `:halt` - Stop traversal immediately
  - `{:halt, value}` - Stop traversal and return the value

  Returns `{:ok, :completed}` if traversal finished normally, or
  `{:ok, {:halted, value}}` if halted early with a value.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1, "A")
      ...> |> Model.ensure_node(2, "B")
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      iex> dfs_visit(graph, 1, fn ctx ->
      ...>   if ctx.label == "B", do: {:halt, :found}, else: :continue
      ...> end)
      {:ok, {:halted, :found}}
  """
  @spec dfs_visit(Model.t(), node_id(), (Context.t() -> visit_result())) ::
          {:ok, :completed | {:halted, any()}} | {:error, :not_found}
  def dfs_visit(graph, start, visitor_fn) do
    if Model.has_node?(graph, start) do
      case dfs_visit_recursive(graph, start, MapSet.new(), visitor_fn) do
        {:halt, value, _visited} -> {:ok, {:halted, value}}
        {:continue, _visited} -> {:ok, :completed}
      end
    else
      {:error, :not_found}
    end
  end

  @doc """
  Finds a path from start to goal using depth-first search.

  Returns `{:ok, path}` where path is a list of node IDs from start to goal,
  or `{:error, :not_found}` if no path exists or nodes don't exist.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      iex> dfs_path(graph, 1, 3)
      {:ok, [1, 2, 3]}
  """
  @spec dfs_path(Model.t(), node_id(), node_id()) :: {:ok, [node_id()]} | {:error, :not_found}
  def dfs_path(graph, start, goal) do
    if Model.has_node?(graph, start) and Model.has_node?(graph, goal) do
      case dfs_path_recursive(graph, start, goal, MapSet.new(), []) do
        nil -> {:error, :not_found}
        path -> {:ok, Enum.reverse(path)}
      end
    else
      {:error, :not_found}
    end
  end

  @doc """
  Performs a breadth-first search traversal starting from a given node.

  Returns a list of node IDs in the order they were visited (level by level).

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 3); g end)
      iex> bfs(graph, 1)
      {:ok, [1, 2, 3]}
  """
  @spec bfs(Model.t(), node_id()) :: {:ok, [node_id()]} | {:error, :not_found}
  def bfs(graph, start) do
    if Model.has_node?(graph, start) do
      visited = bfs_iterative(graph, :queue.from_list([start]), MapSet.new([start]), [])
      {:ok, Enum.reverse(visited)}
    else
      {:error, :not_found}
    end
  end

  @doc """
  Performs a breadth-first search with a visitor function.

  The visitor function receives each node's context and can return:
  - `:continue` - Continue traversal
  - `:halt` - Stop traversal immediately
  - `{:halt, value}` - Stop traversal and return the value

  Returns `{:ok, :completed}` if traversal finished normally, or
  `{:ok, {:halted, value}}` if halted early with a value.
  """
  @spec bfs_visit(Model.t(), node_id(), (Context.t() -> visit_result())) ::
          {:ok, :completed | {:halted, any()}} | {:error, :not_found}
  def bfs_visit(graph, start, visitor_fn) do
    if Model.has_node?(graph, start) do
      case bfs_visit_iterative(graph, :queue.from_list([start]), MapSet.new([start]), visitor_fn) do
        {:halt, value} -> {:ok, {:halted, value}}
        :continue -> {:ok, :completed}
      end
    else
      {:error, :not_found}
    end
  end

  @doc """
  Finds a path from start to goal using breadth-first search.

  BFS finds the shortest path (in terms of number of edges) in an unweighted graph.

  Returns `{:ok, path}` where path is a list of node IDs from start to goal,
  or `{:error, :not_found}` if no path exists or nodes don't exist.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      iex> bfs_path(graph, 1, 3)
      {:ok, [1, 2, 3]}
  """
  @spec bfs_path(Model.t(), node_id(), node_id()) :: {:ok, [node_id()]} | {:error, :not_found}
  def bfs_path(graph, start, goal) do
    if Model.has_node?(graph, start) and Model.has_node?(graph, goal) do
      case bfs_path_iterative(graph, :queue.from_list([{start, [start]}]), MapSet.new([start]), goal) do
        nil -> {:error, :not_found}
        path -> {:ok, path}
      end
    else
      {:error, :not_found}
    end
  end

  @doc """
  Performs a topological sort on a directed acyclic graph (DAG).

  Returns `{:ok, sorted_nodes}` where nodes are in topological order,
  or `{:error, :has_cycle}` if the graph contains a cycle.

  ## Example

      iex> graph = Model.empty()
      ...> |> Model.ensure_node(1)
      ...> |> Model.ensure_node(2)
      ...> |> Model.ensure_node(3)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 1, 2); g end)
      ...> |> then(fn g -> {:ok, g} = Model.add_edge(g, 2, 3); g end)
      iex> topological_sort(graph)
      {:ok, [1, 2, 3]}
  """
  @spec topological_sort(Model.t()) :: {:ok, [node_id()]} | {:error, :has_cycle}
  def topological_sort(graph) do
    all_nodes = Model.node_ids(graph)

    case topo_dfs(graph, all_nodes, MapSet.new(), MapSet.new(), []) do
      {:ok, _visited, sorted} -> {:ok, sorted}
      {:error, :cycle} -> {:error, :has_cycle}
    end
  end

  # Private helper functions for DFS

  defp dfs_recursive(graph, current, visited_set, result) do
    visited_set = MapSet.put(visited_set, current)
    result = [current | result]

    {:ok, neighbors} = Model.out_neighbors(graph, current)

    Enum.reduce(Map.keys(neighbors), {visited_set, result}, fn neighbor, {vis, res} ->
      if neighbor in vis do
        {vis, res}
      else
        dfs_recursive(graph, neighbor, vis, res)
      end
    end)
  end

  defp dfs_visit_recursive(graph, current, visited, visitor_fn) do
    visited = MapSet.put(visited, current)

    ctx = Model.get_node!(graph, current)

    case visitor_fn.(ctx) do
      :halt -> {:halt, nil, visited}
      {:halt, value} -> {:halt, value, visited}
      :continue ->
        {:ok, neighbors} = Model.out_neighbors(graph, current)

        Enum.reduce_while(Map.keys(neighbors), {:continue, visited}, fn neighbor, {_status, vis} ->
          if neighbor in vis do
            {:cont, {:continue, vis}}
          else
            case dfs_visit_recursive(graph, neighbor, vis, visitor_fn) do
              {:halt, value, new_vis} -> {:halt, {:halt, value, new_vis}}
              {:continue, new_vis} -> {:cont, {:continue, new_vis}}
            end
          end
        end)
    end
  end

  defp dfs_path_recursive(graph, current, goal, visited, path) do
    if current == goal do
      [current | path]
    else
      visited = MapSet.put(visited, current)
      {:ok, neighbors} = Model.out_neighbors(graph, current)

      Enum.reduce_while(Map.keys(neighbors), nil, fn neighbor, _acc ->
        if neighbor in visited do
          {:cont, nil}
        else
          case dfs_path_recursive(graph, neighbor, goal, visited, [current | path]) do
            nil -> {:cont, nil}
            found_path -> {:halt, found_path}
          end
        end
      end)
    end
  end

  # Private helper functions for BFS

  defp bfs_iterative(graph, queue, visited, result) do
    case :queue.out(queue) do
      {{:value, current}, rest_queue} ->
        result = [current | result]
        {:ok, neighbors} = Model.out_neighbors(graph, current)

        {new_queue, new_visited} =
          Enum.reduce(Map.keys(neighbors), {rest_queue, visited}, fn neighbor, {q, vis} ->
            if neighbor in vis do
              {q, vis}
            else
              {:queue.in(neighbor, q), MapSet.put(vis, neighbor)}
            end
          end)

        bfs_iterative(graph, new_queue, new_visited, result)

      {:empty, _} ->
        result
    end
  end

  defp bfs_visit_iterative(graph, queue, visited, visitor_fn) do
    case :queue.out(queue) do
      {{:value, current}, rest_queue} ->
        ctx = Model.get_node!(graph, current)

        case visitor_fn.(ctx) do
          :halt -> {:halt, nil}
          {:halt, value} -> {:halt, value}
          :continue ->
            {:ok, neighbors} = Model.out_neighbors(graph, current)

            {new_queue, new_visited} =
              Enum.reduce(Map.keys(neighbors), {rest_queue, visited}, fn neighbor, {q, vis} ->
                if neighbor in vis do
                  {q, vis}
                else
                  {:queue.in(neighbor, q), MapSet.put(vis, neighbor)}
                end
              end)

            bfs_visit_iterative(graph, new_queue, new_visited, visitor_fn)
        end

      {:empty, _} ->
        :continue
    end
  end

  defp bfs_path_iterative(graph, queue, visited, goal) do
    case :queue.out(queue) do
      {{:value, {current, path}}, rest_queue} ->
        if current == goal do
          path
        else
          {:ok, neighbors} = Model.out_neighbors(graph, current)

          {new_queue, new_visited} =
            Enum.reduce(Map.keys(neighbors), {rest_queue, visited}, fn neighbor, {q, vis} ->
              if neighbor in vis do
                {q, vis}
              else
                new_path = path ++ [neighbor]
                {:queue.in({neighbor, new_path}, q), MapSet.put(vis, neighbor)}
              end
            end)

          bfs_path_iterative(graph, new_queue, new_visited, goal)
        end

      {:empty, _} ->
        nil
    end
  end

  # Private helper functions for topological sort

  defp topo_dfs(graph, nodes, visited, temp_visited, result) do
    Enum.reduce_while(nodes, {:ok, visited, result}, fn node, {:ok, vis, acc} ->
      cond do
        node in vis ->
          {:cont, {:ok, vis, acc}}

        node in temp_visited ->
          {:halt, {:error, :cycle}}

        true ->
          case topo_visit(graph, node, vis, temp_visited, acc) do
            {:ok, new_visited, new_result} ->
              {:cont, {:ok, new_visited, new_result}}

            {:error, :cycle} ->
              {:halt, {:error, :cycle}}
          end
      end
    end)
  end

  defp topo_visit(graph, node, visited, temp_visited, result) do
    temp_visited = MapSet.put(temp_visited, node)
    {:ok, neighbors} = Model.out_neighbors(graph, node)

    case visit_neighbors(graph, Map.keys(neighbors), visited, temp_visited, result) do
      {:ok, new_visited, new_result} ->
        visited = MapSet.put(new_visited, node)
        {:ok, visited, [node | new_result]}

      {:error, :cycle} ->
        {:error, :cycle}
    end
  end

  defp visit_neighbors(_graph, [], visited, _temp_visited, result) do
    {:ok, visited, result}
  end

  defp visit_neighbors(graph, [neighbor | rest], visited, temp_visited, result) do
    cond do
      neighbor in visited ->
        visit_neighbors(graph, rest, visited, temp_visited, result)

      neighbor in temp_visited ->
        {:error, :cycle}

      true ->
        case topo_visit(graph, neighbor, visited, temp_visited, result) do
          {:ok, new_visited, new_result} ->
            visit_neighbors(graph, rest, new_visited, temp_visited, new_result)

          {:error, :cycle} ->
            {:error, :cycle}
        end
    end
  end
end
