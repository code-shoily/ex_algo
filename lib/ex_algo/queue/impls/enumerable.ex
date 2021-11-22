alias ExAlgo.Queue

defimpl Enumerable, for: Queue do
  def count(queue), do: {:ok, queue |> Queue.to_list() |> Enum.count()}

  def member?(queue, item) do
    {:ok, queue |> Queue.to_list() |> Enum.member?(item)}
  end

  def reduce(queue, acc, fun) do
    Enumerable.List.reduce(Queue.to_list(queue), acc, fun)
  end

  def slice(_), do: {:error, __MODULE__}
end
