defmodule ExAlgo.Graph.Functional.Model do
  @moduledoc """
  An Inductive Graph implementation.

  This is a functional graph data structure based on Martin Erwig's inductive graphs.
  The graph is represented as a collection of node contexts, where each context contains
  the node's label and its adjacent edges (both incoming and outgoing).

  ## Core Operations

  The fundamental operations are `decompose/2` and `embed/2`, which allow you to
  remove a node from the graph and insert it back. These operations form the basis
  for most graph algorithms.

  ## Example

      iex> graph = ExAlgo.Graph.Functional.Model.empty()
      iex> graph = graph |> ensure_node(1, "A") |> ensure_node(2, "B")
      iex> graph = add_edge(graph, 1, 2, "edge_label")
      iex> has_edge?(graph, 1, 2)
      true
  """

  alias __MODULE__.Context

  @type node_id :: any()
  @type node_label :: any()
  @type edge_label :: any()
  @type t :: %__MODULE__{nodes: %{node_id() => Context.t()}}

  defstruct nodes: %{}

  defmodule Context do
    @moduledoc """
    A node context containing the node's identity, label, and adjacency information.
    """

    @type node_id :: any()
    @type label :: any()
    @type edges :: %{node_id() => label()}
    @type t :: %__MODULE__{
            id: node_id(),
            label: label(),
            in_edges: edges(),
            out_edges: edges()
          }

    defstruct [:id, :label, in_edges: %{}, out_edges: %{}]
  end

  @doc """
  Creates an empty graph.
  """
  @spec empty() :: t()
  def empty, do: %__MODULE__{}

  @doc """
  Checks if the graph is empty.
  """
  @spec empty?(t()) :: boolean()
  def empty?(%__MODULE__{nodes: nodes}), do: nodes == %{}

  @doc """
  Returns the number of nodes in the graph.
  """
  @spec size(t()) :: non_neg_integer()
  def size(%__MODULE__{nodes: nodes}), do: map_size(nodes)

  @doc """
  Checks if a node exists in the graph.
  """
  @spec has_node?(t(), node_id()) :: boolean()
  def has_node?(%__MODULE__{nodes: nodes}, id), do: Map.has_key?(nodes, id)

  @doc """
  Gets a node's context from the graph.

  Returns `{:ok, context}` if the node exists, `{:error, :not_found}` otherwise.
  """
  @spec get_node(t(), node_id()) :: {:ok, Context.t()} | {:error, :not_found}
  def get_node(%__MODULE__{nodes: nodes}, id) do
    case Map.fetch(nodes, id) do
      {:ok, ctx} -> {:ok, ctx}
      :error -> {:error, :not_found}
    end
  end

  @doc """
  Gets a node's context from the graph, raising if not found.
  """
  @spec get_node!(t(), node_id()) :: Context.t()
  def get_node!(%__MODULE__{nodes: nodes}, id) do
    Map.fetch!(nodes, id)
  end

  @doc """
  Returns all node IDs in the graph.
  """
  @spec node_ids(t()) :: [node_id()]
  def node_ids(%__MODULE__{nodes: nodes}), do: Map.keys(nodes)

  @doc """
  Returns all nodes (contexts) in the graph.
  """
  @spec nodes(t()) :: [Context.t()]
  def nodes(%__MODULE__{nodes: nodes}), do: Map.values(nodes)

  @doc """
  Returns the outgoing neighbors of a node.

  Returns `{:ok, neighbors}` where neighbors is a map of `%{neighbor_id => edge_label}`,
  or `{:error, :not_found}` if the node doesn't exist.
  """
  @spec out_neighbors(t(), node_id()) ::
          {:ok, %{node_id() => edge_label()}} | {:error, :not_found}
  def out_neighbors(%__MODULE__{nodes: nodes}, id) do
    case Map.fetch(nodes, id) do
      {:ok, %Context{out_edges: out_edges}} -> {:ok, out_edges}
      :error -> {:error, :not_found}
    end
  end

  @doc """
  Returns the incoming neighbors of a node.

  Returns `{:ok, neighbors}` where neighbors is a map of `%{neighbor_id => edge_label}`,
  or `{:error, :not_found}` if the node doesn't exist.
  """
  @spec in_neighbors(t(), node_id()) :: {:ok, %{node_id() => edge_label()}} | {:error, :not_found}
  def in_neighbors(%__MODULE__{nodes: nodes}, id) do
    case Map.fetch(nodes, id) do
      {:ok, %Context{in_edges: in_edges}} -> {:ok, in_edges}
      :error -> {:error, :not_found}
    end
  end

  @doc """
  Returns all neighbors (both incoming and outgoing) of a node.

  Returns `{:ok, neighbor_ids}` as a list of unique node IDs,
  or `{:error, :not_found}` if the node doesn't exist.
  """
  @spec neighbors(t(), node_id()) :: {:ok, [node_id()]} | {:error, :not_found}
  def neighbors(%__MODULE__{nodes: nodes}, id) do
    case Map.fetch(nodes, id) do
      {:ok, %Context{in_edges: in_edges, out_edges: out_edges}} ->
        neighbor_ids =
          (Map.keys(in_edges) ++ Map.keys(out_edges))
          |> Enum.uniq()

        {:ok, neighbor_ids}

      :error ->
        {:error, :not_found}
    end
  end

  @doc """
  Checks if an edge exists between two nodes.
  """
  @spec has_edge?(t(), node_id(), node_id()) :: boolean()
  def has_edge?(%__MODULE__{nodes: nodes}, from_id, to_id) do
    case Map.fetch(nodes, from_id) do
      {:ok, %Context{out_edges: out_edges}} -> Map.has_key?(out_edges, to_id)
      :error -> false
    end
  end

  @doc """
  Gets the label of an edge between two nodes.

  Returns `{:ok, label}` if the edge exists, `{:error, :not_found}` otherwise.
  """
  @spec get_edge(t(), node_id(), node_id()) :: {:ok, edge_label()} | {:error, :not_found}
  def get_edge(%__MODULE__{nodes: nodes}, from_id, to_id) do
    case Map.fetch(nodes, from_id) do
      {:ok, %Context{out_edges: out_edges}} ->
        case Map.fetch(out_edges, to_id) do
          {:ok, label} -> {:ok, label}
          :error -> {:error, :not_found}
        end

      :error ->
        {:error, :not_found}
    end
  end

  @doc """
  Adds an edge from `from_id` to `to_id` with an optional label.

  Both nodes must exist in the graph. If the edge already exists, it will be updated
  with the new label.

  Returns `{:ok, graph}` on success, or `{:error, reason}` if either node doesn't exist.
  """
  @spec add_edge(t(), node_id(), node_id(), edge_label()) ::
          {:ok, t()} | {:error, :source_not_found | :target_not_found}
  def add_edge(%__MODULE__{nodes: nodes}, from_id, to_id, label \\ nil) do
    cond do
      not Map.has_key?(nodes, from_id) ->
        {:error, :source_not_found}

      not Map.has_key?(nodes, to_id) ->
        {:error, :target_not_found}

      true ->
        new_nodes =
          nodes
          |> Map.update!(from_id, fn ctx ->
            %{ctx | out_edges: Map.put(ctx.out_edges, to_id, label)}
          end)
          |> Map.update!(to_id, fn ctx ->
            %{ctx | in_edges: Map.put(ctx.in_edges, from_id, label)}
          end)

        {:ok, %__MODULE__{nodes: new_nodes}}
    end
  end

  @doc """
  Adds an edge from `from_id` to `to_id` with an optional label, raising on error.
  """
  @spec add_edge!(t(), node_id(), node_id(), edge_label()) :: t()
  def add_edge!(graph, from_id, to_id, label \\ nil) do
    case add_edge(graph, from_id, to_id, label) do
      {:ok, new_graph} -> new_graph
      {:error, reason} -> raise "Failed to add edge: #{reason}"
    end
  end

  @doc """
  Removes an edge from `from_id` to `to_id`.

  Returns `{:ok, graph}` whether or not the edge existed.
  """
  @spec remove_edge(t(), node_id(), node_id()) :: {:ok, t()}
  def remove_edge(%__MODULE__{nodes: nodes}, from_id, to_id) do
    new_nodes =
      nodes
      |> Map.update(from_id, nil, fn
        nil -> nil
        ctx -> %{ctx | out_edges: Map.delete(ctx.out_edges, to_id)}
      end)
      |> Map.update(to_id, nil, fn
        nil -> nil
        ctx -> %{ctx | in_edges: Map.delete(ctx.in_edges, from_id)}
      end)

    {:ok, %__MODULE__{nodes: new_nodes}}
  end

  @doc """
  Removes an edge from `from_id` to `to_id`, raising on error.
  """
  @spec remove_edge!(t(), node_id(), node_id()) :: t()
  def remove_edge!(graph, from_id, to_id) do
    {:ok, new_graph} = remove_edge(graph, from_id, to_id)
    new_graph
  end

  @doc """
  Decomposes the graph by removing a node and returning its context.

  This is one of the fundamental operations for inductive graphs. It removes
  a node from the graph and returns the node's context along with the remaining graph.
  All edges to/from the removed node are also removed from adjacent nodes.

  Returns `{:ok, context, graph}` if the node exists, `{:error, :not_found}` otherwise.
  """
  @spec decompose(t(), node_id()) :: {:ok, Context.t(), t()} | {:error, :not_found}
  def decompose(%__MODULE__{nodes: nodes}, id) do
    case Map.pop(nodes, id) do
      {nil, _} ->
        {:error, :not_found}

      {ctx, remaining_nodes} ->
        new_nodes = purge_all_links_to(remaining_nodes, id, ctx)
        {:ok, ctx, %__MODULE__{nodes: new_nodes}}
    end
  end

  @doc """
  Embeds a node context back into the graph.

  This is the inverse of `decompose/2`. It inserts a node into the graph and
  restores all edges to/from adjacent nodes. If a node with the same ID already
  exists, it will be replaced.
  """
  @spec embed(Context.t(), t()) :: t()
  def embed(%Context{id: id} = ctx, %__MODULE__{nodes: nodes}) do
    new_nodes = restore_all_links_from(nodes, ctx)
    %__MODULE__{nodes: Map.put(new_nodes, id, ctx)}
  end

  @doc """
  Ensures a node exists in the graph.

  If the node already exists, the graph is returned unchanged. Otherwise, a new
  node with the given ID and label is added.
  """
  @spec ensure_node(t(), node_id(), node_label()) :: t()
  def ensure_node(%__MODULE__{nodes: nodes} = graph, id, label \\ nil) do
    if Map.has_key?(nodes, id) do
      graph
    else
      new_ctx = %Context{id: id, label: label}
      %__MODULE__{nodes: Map.put(nodes, id, new_ctx)}
    end
  end

  @doc """
  Adds or updates a node in the graph.

  If the node doesn't exist, it's created. If it exists, its label is updated.
  Existing edges are preserved.
  """
  @spec put_node(t(), node_id(), node_label()) :: t()
  def put_node(%__MODULE__{nodes: nodes}, id, label) do
    case Map.fetch(nodes, id) do
      {:ok, ctx} ->
        %__MODULE__{nodes: Map.put(nodes, id, %{ctx | label: label})}

      :error ->
        new_ctx = %Context{id: id, label: label}
        %__MODULE__{nodes: Map.put(nodes, id, new_ctx)}
    end
  end

  @doc """
  Removes a node and all its edges from the graph.

  Returns `{:ok, graph}` whether or not the node existed.
  """
  @spec remove_node(t(), node_id()) :: {:ok, t()}
  def remove_node(graph, id) do
    case decompose(graph, id) do
      {:ok, _ctx, new_graph} -> {:ok, new_graph}
      {:error, :not_found} -> {:ok, graph}
    end
  end

  @doc """
  Removes a node and all its edges from the graph, raising on error.
  """
  @spec remove_node!(t(), node_id()) :: t()
  def remove_node!(graph, id) do
    {:ok, new_graph} = remove_node(graph, id)
    new_graph
  end

  @doc """
  Returns all edges in the graph as a list of tuples `{from_id, to_id, label}`.
  """
  @spec edges(t()) :: [{node_id(), node_id(), edge_label()}]
  def edges(%__MODULE__{nodes: nodes}) do
    Enum.flat_map(nodes, fn {from_id, %Context{out_edges: out_edges}} ->
      Enum.map(out_edges, fn {to_id, label} ->
        {from_id, to_id, label}
      end)
    end)
  end

  @doc """
  Returns the out-degree of a node (number of outgoing edges).

  Returns `{:ok, degree}` if the node exists, `{:error, :not_found}` otherwise.
  """
  @spec out_degree(t(), node_id()) :: {:ok, non_neg_integer()} | {:error, :not_found}
  def out_degree(%__MODULE__{nodes: nodes}, id) do
    case Map.fetch(nodes, id) do
      {:ok, %Context{out_edges: out_edges}} -> {:ok, map_size(out_edges)}
      :error -> {:error, :not_found}
    end
  end

  @doc """
  Returns the in-degree of a node (number of incoming edges).

  Returns `{:ok, degree}` if the node exists, `{:error, :not_found}` otherwise.
  """
  @spec in_degree(t(), node_id()) :: {:ok, non_neg_integer()} | {:error, :not_found}
  def in_degree(%__MODULE__{nodes: nodes}, id) do
    case Map.fetch(nodes, id) do
      {:ok, %Context{in_edges: in_edges}} -> {:ok, map_size(in_edges)}
      :error -> {:error, :not_found}
    end
  end

  @doc """
  Returns the degree of a node (total number of edges, both in and out).

  Returns `{:ok, degree}` if the node exists, `{:error, :not_found}` otherwise.
  """
  @spec degree(t(), node_id()) :: {:ok, non_neg_integer()} | {:error, :not_found}
  def degree(%__MODULE__{nodes: nodes}, id) do
    case Map.fetch(nodes, id) do
      {:ok, %Context{in_edges: in_edges, out_edges: out_edges}} ->
        # Count unique neighbors to avoid double-counting bidirectional edges
        total =
          (Map.keys(in_edges) ++ Map.keys(out_edges))
          |> Enum.uniq()
          |> length()

        {:ok, total}

      :error ->
        {:error, :not_found}
    end
  end

  @doc """
  Performs a map operation over all nodes in the graph.

  The function receives each context and should return a modified context.
  This is useful for bulk updates to node labels or other transformations.
  """
  @spec map_nodes(t(), (Context.t() -> Context.t())) :: t()
  def map_nodes(%__MODULE__{nodes: nodes}, fun) do
    new_nodes = Map.new(nodes, fn {id, ctx} -> {id, fun.(ctx)} end)
    %__MODULE__{nodes: new_nodes}
  end

  @doc """
  Filters nodes in the graph based on a predicate function.

  The function receives each context and should return true to keep the node.
  Nodes that are removed will have all their edges removed from adjacent nodes.
  """
  @spec filter_nodes(t(), (Context.t() -> boolean())) :: t()
  def filter_nodes(%__MODULE__{nodes: nodes} = graph, fun) do
    nodes_to_remove =
      nodes
      |> Enum.reject(fn {_id, ctx} -> fun.(ctx) end)
      |> Enum.map(fn {id, _ctx} -> id end)

    Enum.reduce(nodes_to_remove, graph, fn id, acc ->
      {:ok, new_graph} = remove_node(acc, id)
      new_graph
    end)
  end

  @doc """
  Folds over all nodes in the graph.

  The function receives the accumulator and each context, and should return
  a new accumulator.
  """
  @spec fold_nodes(t(), acc, (Context.t(), acc -> acc)) :: acc when acc: any()
  def fold_nodes(%__MODULE__{nodes: nodes}, initial, fun) do
    Enum.reduce(nodes, initial, fn {_id, ctx}, acc -> fun.(ctx, acc) end)
  end

  # Private helper functions

  defp purge_all_links_to(nodes, id, %Context{in_edges: in_refs, out_edges: out_refs}) do
    nodes
    |> purge_direction(id, out_refs, :in_edges)
    |> purge_direction(id, in_refs, :out_edges)
  end

  defp purge_direction(nodes, target_id, neighbors, field) do
    Enum.reduce(neighbors, nodes, fn {neighbor_id, _label}, acc ->
      # Use Map.update instead of Map.update! to handle missing neighbors gracefully
      Map.update(acc, neighbor_id, nil, fn
        nil ->
          nil

        ctx ->
          updated_map = Map.delete(Map.get(ctx, field), target_id)
          Map.put(ctx, field, updated_map)
      end)
    end)
  end

  defp restore_all_links_from(nodes, %Context{id: id, in_edges: in_refs, out_edges: out_refs}) do
    nodes
    |> restore_direction(id, out_refs, :in_edges)
    |> restore_direction(id, in_refs, :out_edges)
  end

  defp restore_direction(nodes, target_id, neighbors, field) do
    Enum.reduce(neighbors, nodes, fn {neighbor_id, label}, acc ->
      # Use Map.update instead of Map.update! to handle missing neighbors gracefully
      Map.update(acc, neighbor_id, nil, fn
        nil ->
          nil

        ctx ->
          updated_map = Map.put(Map.get(ctx, field), target_id, label)
          Map.put(ctx, field, updated_map)
      end)
    end)
  end

  defimpl ExAlgo.Visualizer, for: ExAlgo.Graph.Functional.Model do
    alias ExAlgo.Graph.Functional.Model

    def suitable?(_), do: true

    def to_mermaid(graph) do
      edges_str =
        ExAlgo.Graph.Functional.Model.edges(graph)
        |> Enum.map(fn {u, v, w} ->
          label = if w, do: "|#{w}|", else: ""
          "    #{u} -->#{label} #{v}"
        end)
        |> Enum.join("\n")

      "graph TD\n" <> edges_str
    end

    def to_text(graph) do
      # A simple summary for console debugging
      "FunctionalGraph<nodes: #{Model.size(graph)}, edges: #{length(Model.edges(graph))}>"
    end
  end

  defimpl Inspect, for: ExAlgo.Graph.Functional.Model do
    import Inspect.Algebra

    def inspect(graph, opts) do
      node_count = ExAlgo.Graph.Functional.Model.size(graph)
      edge_count = length(ExAlgo.Graph.Functional.Model.edges(graph))

      concat([
        "#ExAlgo.Graph<",
        to_doc("nodes: #{node_count}, edges: #{edge_count}", opts),
        ">"
      ])
    end
  end
end
