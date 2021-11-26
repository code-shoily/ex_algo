alias ExAlgo.List.{CircularList, LinkedList}

defimpl Collectable, for: LinkedList do
  def into(%LinkedList{} = list) do
    {list, &insert/2}
  end

  defp insert(list, {:cont, item}), do: LinkedList.insert(list, item)
  defp insert(list, :done), do: list.container |> Enum.reverse() |> LinkedList.from()
  defp insert(_list, :halt), do: :ok
end

defimpl Collectable, for: CircularList do
  def into(%CircularList{} = list) do
    {list, &insert/2}
  end

  defp insert(list, {:cont, item}), do: CircularList.insert(list, item)
  defp insert(list, :done), do: list
  defp insert(_list, :halt), do: :ok
end
