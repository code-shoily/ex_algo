alias ExAlgo.List.{CircularList, LinkedList}

defimpl Inspect, for: LinkedList do
  import Inspect.Algebra

  def inspect(%LinkedList{container: container}, opts) do
    concat(["#ExAlgo.LinkedList<", to_doc(Enum.to_list(container), opts), ">"])
  end
end

defimpl Inspect, for: CircularList do
  import Inspect.Algebra

  def inspect(%CircularList{} = circular_list, opts) do
    concat(["#ExAlgo.CircularList<", to_doc(CircularList.to_list(circular_list), opts), ">"])
  end
end
