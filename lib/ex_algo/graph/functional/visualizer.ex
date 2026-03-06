defmodule ExAlgo.Graph.Functional.Visualizer do
  @moduledoc """
  Protocol implementations for ExAlgo.Graph.Functional.Model visualization.
  """

  defimpl ExAlgo.Visualizer, for: ExAlgo.Graph.Functional.Model do
    alias ExAlgo.Graph.Functional.Model

    def suitable?(_), do: true

    def to_mermaid(graph) do
      nodes_str =
        Model.nodes(graph)
        |> Enum.map(fn ctx ->
          label = ctx.label || ctx.id
          "    #{inspect(ctx.id)}[#{inspect(label)}]"
        end)
        |> Enum.join("\n")

      edges_str =
        Model.edges(graph)
        |> Enum.map(fn {u, v, w} ->
          label = if w, do: "|#{inspect(w)}|", else: ""
          "    #{inspect(u)} -->#{label} #{inspect(v)}"
        end)
        |> Enum.join("\n")

      "graph TD\n" <> nodes_str <> "\n" <> edges_str
    end

    def to_text(graph) do
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
