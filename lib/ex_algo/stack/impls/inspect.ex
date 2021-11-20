alias ExAlgo.Stack

defimpl Inspect, for: Stack do
  import Inspect.Algebra

  def inspect(%Stack{container: container}, opts) do
    concat(["#ExAlgo.Stack<", to_doc(Enum.to_list(container), opts), ">"])
  end
end
