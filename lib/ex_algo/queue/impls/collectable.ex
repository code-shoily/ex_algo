alias ExAlgo.Queue

defimpl Collectable, for: Queue do
  def into(queue) do
    {queue, &enqueue/2}
  end

  defp enqueue(queue, {:cont, item}), do: Queue.enqueue(queue, item)
  defp enqueue(queue, :done), do: queue
  defp enqueue(_queue, :halt), do: :ok
end
