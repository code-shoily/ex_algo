alias ExAlgo.List.{CircularList, LinkedList}

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

defimpl Enumerable, for: CircularList do
  def count(%CircularList{visited: visited, upcoming: upcoming}) do
    {:ok, Enum.count(visited) + Enum.count(upcoming)}
  end

  def member?(%CircularList{visited: visited, upcoming: upcoming}, item) do
    {:ok, Enum.member?(visited, item) || Enum.member?(upcoming, item)}
  end

  def reduce(%CircularList{} = list, acc, fun) do
    Enumerable.List.reduce(CircularList.to_list(list), acc, fun)
  end

  def slice(%CircularList{}), do: {:error, __MODULE__}
end
