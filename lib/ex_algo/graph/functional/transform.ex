defmodule ExAlgo.Graph.Functional.Transform do
  @moduledoc """
  Structural transformations for inductive graphs.
  Useful for graph optimization, simplification, and analysis.
  """

  alias ExAlgo.Graph.Functional.Model
  alias ExAlgo.Graph.Functional.Model.Context

  @doc """
  Reverses all edges in the graph.
  In a DAG, this effectively flips the flow of data.
  """
  def reverse(graph) do
    # This is a perfect use case for our inductive 'map' pattern.
    # We swap in_edges and out_edges for every context.
    Model.map_nodes(graph, fn %Context{in_edges: in_e, out_edges: out_e} = ctx ->
      %{ctx | in_edges: out_e, out_edges: in_e}
    end)
  end

  @doc """
  Contracts an edge between two nodes, merging 'v' into 'u'.
  The new node 'u' inherits all of 'v's edges.

  Useful for "Operator Fusion" in Quarry (e.g., merging a Filter into a Scan).
  """
  def contract_edge(graph, u_id, v_id) do
    with {:ok, u_ctx, g1} <- Model.decompose(graph, u_id),
         {:ok, v_ctx, g2} <- Model.decompose(g1, v_id) do
      # Merge edges, removing the self-loop that would be created between u and v
      new_in = Map.merge(u_ctx.in_edges, v_ctx.in_edges) |> Map.delete(u_id) |> Map.delete(v_id)

      new_out =
        Map.merge(u_ctx.out_edges, v_ctx.out_edges) |> Map.delete(u_id) |> Map.delete(v_id)

      new_u = %{u_ctx | in_edges: new_in, out_edges: new_out}

      {:ok, Model.embed(new_u, g2)}
    else
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  @doc """
  Finds and returns the induced subgraph containing only the specified nodes.
  """
  def subgraph(graph, ids) do
    id_set = MapSet.new(ids)

    # We filter out any node not in our set.
    # Model.filter_nodes already handles purging edges to deleted nodes.
    Model.filter_nodes(graph, fn ctx -> ctx.id in id_set end)
  end

  @doc """
  "Cleans" the graph by removing any nodes that have no edges.
  """
  def clear_isolated(graph) do
    Model.filter_nodes(graph, fn ctx ->
      map_size(ctx.in_edges) > 0 or map_size(ctx.out_edges) > 0
    end)
  end
end
