alias ExAlgo.List.LinkedList

defimpl Enumerable, for: LinkedList do
  def count(%LinkedList{container: container}), do: {:ok, Enum.count(container)}

  def member?(%LinkedList{container: container}, item) do
    {:ok, Enum.member?(container, item)}
  end

  def reduce(%LinkedList{container: container}, acc, fun) do
    Enumerable.List.reduce(Enum.to_list(container), acc, fun)
  end

  def slice(%LinkedList{}), do: {:error, __MODULE__}
end
