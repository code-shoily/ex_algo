defprotocol ExAlgo.Visualizer do
  @doc "Checks if the data structure is small enough to be rendered without a mess."
  def suitable?(data)

  @doc "Returns a plain-text ASCII representation."
  def to_text(data)

  @doc "Returns a string formatted for Mermaid.js."
  def to_mermaid(data)
end
