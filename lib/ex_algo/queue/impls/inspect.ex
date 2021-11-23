alias ExAlgo.Queue

defimpl Inspect, for: Queue do
  import Inspect.Algebra

  def inspect(queue, opts) do
    concat(["#ExAlgo.Queue<", to_doc(Queue.to_list(queue), opts), ">"])
  end
end
