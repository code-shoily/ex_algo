alias ExAlgo.List.{BidirectionalList, CircularList, LinkedList}

defimpl Inspect, for: LinkedList do
  import Inspect.Algebra

  def inspect(%LinkedList{container: container}, opts) do
    concat(["#ExAlgo.LinkedList<", to_doc(Enum.to_list(container), opts), ">"])
  end
end

defimpl Inspect, for: CircularList do
  import Inspect.Algebra

  def inspect(%CircularList{} = circular_list, opts) do
    left = to_doc(circular_list.visited, opts)
    right = to_doc(circular_list.upcoming, opts)

    concat([
      "#ExAlgo.CircularList<",
      left,
      "|",
      right,
      ">"
    ])
  end
end

defimpl Inspect, for: BidirectionalList do
  import Inspect.Algebra

  def inspect(%BidirectionalList{} = circular_list, opts) do
    left = to_doc(circular_list.visited, opts)
    right = to_doc(circular_list.upcoming, opts)

    concat([
      "#ExAlgo.BidirectionalList<",
      left,
      "|",
      right,
      ">"
    ])
  end
end
