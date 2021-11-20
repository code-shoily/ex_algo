alias ExAlgo.Stack

defimpl Enumerable, for: Stack do
  def count(%Stack{container: container}), do: {:ok, Enum.count(container)}

  def member?(%Stack{container: container}, item) do
    {:ok, Enum.member?(container, item)}
  end

  def reduce(%Stack{container: container}, acc, fun) do
    Enumerable.List.reduce(Enum.to_list(container), acc, fun)
  end

  def slice(%Stack{}), do: {:error, __MODULE__}
end
