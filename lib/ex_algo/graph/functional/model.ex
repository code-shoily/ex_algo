defmodule ExAlgo.Graph.Functional.Model do
  @moduledoc """
  An Inductive Graph implementation.

  This is a functional graph data structure based on Martin Erwig's inductive graphs.
  The graph is represented as a collection of node contexts, where each context contains
  the node's label and its adjacent edges (both incoming and outgoing).

  ## Core Operations

  The fundamental operations are `match/2` and `embed/2`, which allow you to
  remove a node from the graph and insert it back. These operations form the basis
  for most graph algorithms.
  """

  alias __MODULE__.Context

  @type node_id :: any()
  @type node_label :: any()
  @type edge_label :: any()
  @type direction :: :directed | :undirected
  @type t :: %__MODULE__{
          nodes: %{node_id() => Context.t()},
          direction: direction()
        }

  defstruct nodes: %{}, direction: :directed

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

  @doc "Creates a new graph with specified direction (defaults to :directed)."
  @spec new(direction()) :: t()
  def new(direction \\ :directed), do: %__MODULE__{direction: direction}

  @doc "Creates an empty directed graph."
  @spec empty() :: t()
  def empty, do: new(:directed)

  @doc "Checks if the graph is empty."
  @spec empty?(t()) :: boolean()
  def empty?(%__MODULE__{nodes: nodes}), do: nodes == %{}

  @doc "Returns the number of nodes in the graph."
  @spec size(t()) :: non_neg_integer()
  def size(%__MODULE__{nodes: nodes}), do: map_size(nodes)

  @doc "Checks if a node exists in the graph."
  @spec has_node?(t(), node_id()) :: boolean()
  def has_node?(%__MODULE__{nodes: nodes}, id), do: Map.has_key?(nodes, id)

  @doc "Gets a node's context from the graph."
  @spec get_node(t(), node_id()) :: {:ok, Context.t()} | {:error, :not_found}
  def get_node(%__MODULE__{nodes: nodes}, id) do
    case Map.fetch(nodes, id) do
      {:ok, ctx} -> {:ok, ctx}
      :error -> {:error, :not_found}
    end
  end

  @doc "Gets a node's context from the graph, raising if not found."
  @spec get_node!(t(), node_id()) :: Context.t()
  def get_node!(%__MODULE__{nodes: nodes}, id) do
    Map.fetch!(nodes, id)
  end

  @doc "Returns all node IDs in the graph."
  @spec node_ids(t()) :: [node_id()]
  def node_ids(%__MODULE__{nodes: nodes}), do: Map.keys(nodes)

  @doc "Returns all nodes (contexts) in the graph."
  @spec nodes(t()) :: [Context.t()]
  def nodes(%__MODULE__{nodes: nodes}), do: Map.values(nodes)

  @doc "Returns the outgoing neighbors of a node."
  @spec out_neighbors(t(), node_id()) ::
          {:ok, %{node_id() => edge_label()}} | {:error, :not_found}
  def out_neighbors(%__MODULE__{nodes: nodes}, id) do
    case Map.fetch(nodes, id) do
      {:ok, %Context{out_edges: out_edges}} -> {:ok, out_edges}
      :error -> {:error, :not_found}
    end
  end

  @doc "Returns the incoming neighbors of a node."
  @spec in_neighbors(t(), node_id()) :: {:ok, %{node_id() => edge_label()}} | {:error, :not_found}
  def in_neighbors(%__MODULE__{nodes: nodes}, id) do
    case Map.fetch(nodes, id) do
      {:ok, %Context{in_edges: in_edges}} -> {:ok, in_edges}
      :error -> {:error, :not_found}
    end
  end

  @doc "Returns all unique neighbors (both incoming and outgoing) of a node."
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

  @doc "Checks if an edge exists between two nodes."
  @spec has_edge?(t(), node_id(), node_id()) :: boolean()
  def has_edge?(%__MODULE__{nodes: nodes}, from_id, to_id) do
    case Map.fetch(nodes, from_id) do
      {:ok, %Context{out_edges: out_edges}} -> Map.has_key?(out_edges, to_id)
      :error -> false
    end
  end

  @doc "Gets the label of an edge between two nodes."
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

  @doc "Adds an edge, respecting the graph's directionality."
  @spec add_edge(t(), node_id(), node_id(), edge_label()) ::
          {:ok, t()} | {:error, :source_not_found | :target_not_found}
  def add_edge(graph, from_id, to_id, label \\ nil)

  def add_edge(%__MODULE__{direction: :undirected} = graph, from_id, to_id, label) do
    add_undirected_edge(graph, from_id, to_id, label)
  end

  def add_edge(%__MODULE__{nodes: nodes, direction: :directed} = graph, from_id, to_id, label) do
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

        {:ok, %{graph | nodes: new_nodes}}
    end
  end

  @doc "Adds an undirected edge between two nodes."
  @spec add_undirected_edge(t(), node_id(), node_id(), edge_label()) ::
          {:ok, t()} | {:error, :source_not_found | :target_not_found}
  def add_undirected_edge(%__MODULE__{nodes: nodes} = graph, u, v, label \\ nil) do
    cond do
      not Map.has_key?(nodes, u) ->
        {:error, :source_not_found}

      not Map.has_key?(nodes, v) ->
        {:error, :target_not_found}

      true ->
        new_nodes =
          nodes
          |> Map.update!(u, fn ctx ->
            ctx
            |> Map.update!(:out_edges, &Map.put(&1, v, label))
            |> Map.update!(:in_edges, &Map.put(&1, v, label))
          end)
          |> Map.update!(v, fn ctx ->
            ctx
            |> Map.update!(:out_edges, &Map.put(&1, u, label))
            |> Map.update!(:in_edges, &Map.put(&1, u, label))
          end)

        {:ok, %{graph | nodes: new_nodes}}
    end
  end

  @doc "Adds an edge, raising on error."
  @spec add_edge!(t(), node_id(), node_id(), edge_label()) :: t()
  def add_edge!(graph, from_id, to_id, label \\ nil) do
    case add_edge(graph, from_id, to_id, label) do
      {:ok, new_graph} -> new_graph
      {:error, reason} -> raise "Failed to add edge: #{reason}"
    end
  end

  @doc "Adds an undirected edge, raising on error."
  @spec add_undirected_edge!(t(), node_id(), node_id(), edge_label()) :: t()
  def add_undirected_edge!(graph, u, v, label \\ nil) do
    case add_undirected_edge(graph, u, v, label) do
      {:ok, new_graph} -> new_graph
      {:error, reason} -> raise "Failed to add undirected edge: #{reason}"
    end
  end

  @doc "Removes an edge, respecting graph directionality."
  @spec remove_edge(t(), node_id(), node_id()) :: {:ok, t()}
  def remove_edge(%__MODULE__{direction: :undirected} = graph, u, v) do
    remove_undirected_edge(graph, u, v)
  end

  def remove_edge(%__MODULE__{nodes: nodes, direction: :directed} = graph, from_id, to_id) do
    new_nodes =
      nodes
      |> update_if_exists(from_id, fn ctx ->
        %{ctx | out_edges: Map.delete(ctx.out_edges, to_id)}
      end)
      |> update_if_exists(to_id, fn ctx ->
        %{ctx | in_edges: Map.delete(ctx.in_edges, from_id)}
      end)

    {:ok, %{graph | nodes: new_nodes}}
  end

  @doc "Removes an undirected edge between two nodes."
  @spec remove_undirected_edge(t(), node_id(), node_id()) :: {:ok, t()}
  def remove_undirected_edge(%__MODULE__{nodes: nodes} = graph, u, v) do
    new_nodes =
      nodes
      |> update_if_exists(u, fn ctx ->
        ctx
        |> Map.update!(:out_edges, &Map.delete(&1, v))
        |> Map.update!(:in_edges, &Map.delete(&1, v))
      end)
      |> update_if_exists(v, fn ctx ->
        ctx
        |> Map.update!(:out_edges, &Map.delete(&1, u))
        |> Map.update!(:in_edges, &Map.delete(&1, u))
      end)

    {:ok, %{graph | nodes: new_nodes}}
  end

  @doc "Removes an undirected edge, raising on error."
  @spec remove_undirected_edge!(t(), node_id(), node_id()) :: t()
  def remove_undirected_edge!(graph, u, v) do
    {:ok, new_graph} = remove_undirected_edge(graph, u, v)
    new_graph
  end

  @doc "Removes an edge, raising on error."
  @spec remove_edge!(t(), node_id(), node_id()) :: t()
  def remove_edge!(graph, from_id, to_id) do
    {:ok, new_graph} = remove_edge(graph, from_id, to_id)
    new_graph
  end

  @doc "Matches a node in the graph, returning its context and the remaining graph."
  @spec match(t(), node_id()) :: {:ok, Context.t(), t()} | {:error, :not_found}
  def match(%__MODULE__{nodes: nodes} = graph, id) do
    case Map.pop(nodes, id) do
      {nil, _} ->
        {:error, :not_found}

      {ctx, remaining_nodes} ->
        new_nodes = purge_all_links_to(remaining_nodes, id, ctx)
        {:ok, ctx, %{graph | nodes: new_nodes}}
    end
  end

  @doc "Matches an arbitrary node from the graph."
  @spec match_any(t()) :: {:ok, Context.t(), t()} | {:error, :empty}
  def match_any(%__MODULE__{nodes: nodes} = graph) do
    case Map.keys(nodes) do
      [] -> {:error, :empty}
      [id | _] -> match(graph, id)
    end
  end

  @doc "Embeds a node context back into the graph."
  @spec embed(Context.t(), t()) :: t()
  def embed(%Context{id: id} = ctx, %__MODULE__{nodes: nodes}) do
    new_nodes = restore_all_links_from(nodes, ctx)
    %__MODULE__{nodes: Map.put(new_nodes, id, ctx)}
  end

  @doc "Ensures a node exists in the graph."
  @spec ensure_node(t(), node_id(), node_label()) :: t()
  def ensure_node(%__MODULE__{nodes: nodes} = graph, id, label \\ nil) do
    if Map.has_key?(nodes, id) do
      graph
    else
      new_ctx = %Context{id: id, label: label}
      %{graph | nodes: Map.put(nodes, id, new_ctx)}
    end
  end

  @doc "Adds or updates a node in the graph."
  @spec put_node(t(), node_id(), node_label()) :: t()
  def put_node(%__MODULE__{nodes: nodes} = graph, id, label) do
    case Map.fetch(nodes, id) do
      {:ok, ctx} ->
        %{graph | nodes: Map.put(nodes, id, %{ctx | label: label})}

      :error ->
        new_ctx = %Context{id: id, label: label}
        %{graph | nodes: Map.put(nodes, id, new_ctx)}
    end
  end

  @doc "Removes a node and all its edges from the graph."
  @spec remove_node(t(), node_id()) :: {:ok, t()}
  def remove_node(graph, id) do
    case match(graph, id) do
      {:ok, _ctx, new_graph} -> {:ok, new_graph}
      {:error, :not_found} -> {:ok, graph}
    end
  end

  @doc "Removes a node and all its edges from the graph, raising on error."
  @spec remove_node!(t(), node_id()) :: t()
  def remove_node!(graph, id) do
    {:ok, new_graph} = remove_node(graph, id)
    new_graph
  end

  @doc "Returns all edges in the graph as a list of tuples `{from_id, to_id, label}`."
  @spec edges(t()) :: [{node_id(), node_id(), edge_label()}]
  def edges(%__MODULE__{nodes: nodes}) do
    Enum.flat_map(nodes, fn {from_id, %Context{out_edges: out_edges}} ->
      Enum.map(out_edges, fn {to_id, label} ->
        {from_id, to_id, label}
      end)
    end)
  end

  @doc "Returns the out-degree of a node."
  @spec out_degree(t(), node_id()) :: {:ok, non_neg_integer()} | {:error, :not_found}
  def out_degree(%__MODULE__{nodes: nodes}, id) do
    case Map.fetch(nodes, id) do
      {:ok, %Context{out_edges: out_edges}} -> {:ok, map_size(out_edges)}
      :error -> {:error, :not_found}
    end
  end

  @doc "Returns the in-degree of a node."
  @spec in_degree(t(), node_id()) :: {:ok, non_neg_integer()} | {:error, :not_found}
  def in_degree(%__MODULE__{nodes: nodes}, id) do
    case Map.fetch(nodes, id) do
      {:ok, %Context{in_edges: in_edges}} -> {:ok, map_size(in_edges)}
      :error -> {:error, :not_found}
    end
  end

  @doc "Returns the total degree of a node (in_degree + out_degree)."
  @spec degree(t(), node_id()) :: {:ok, non_neg_integer()} | {:error, :not_found}
  def degree(%__MODULE__{nodes: nodes}, id) do
    case Map.fetch(nodes, id) do
      {:ok, %Context{in_edges: in_edges, out_edges: out_edges}} ->
        {:ok, map_size(in_edges) + map_size(out_edges)}

      :error ->
        {:error, :not_found}
    end
  end

  # --- Private Helper Functions ---

  defp purge_all_links_to(nodes, id, %Context{in_edges: in_refs, out_edges: out_refs}) do
    nodes
    |> purge_direction(id, out_refs, :in_edges)
    |> purge_direction(id, in_refs, :out_edges)
  end

  defp purge_direction(nodes, target_id, neighbors, field) do
    Enum.reduce(neighbors, nodes, fn {neighbor_id, _label}, acc ->
      update_if_exists(acc, neighbor_id, fn ctx ->
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
      update_if_exists(acc, neighbor_id, fn ctx ->
        updated_map = Map.put(Map.get(ctx, field), target_id, label)
        Map.put(ctx, field, updated_map)
      end)
    end)
  end

  defp update_if_exists(map, key, update_fun) do
    case Map.fetch(map, key) do
      {:ok, val} -> Map.put(map, key, update_fun.(val))
      :error -> map
    end
  end
end
