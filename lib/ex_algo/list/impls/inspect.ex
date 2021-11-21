alias ExAlgo.List.LinkedList

defimpl Inspect, for: LinkedList do
  import Inspect.Algebra

  def inspect(%LinkedList{container: container}, opts) do
    concat(["#ExAlgo.LinkedList<", to_doc(Enum.to_list(container), opts), ">"])
  end
end
