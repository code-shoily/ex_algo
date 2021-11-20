alias ExAlgo.Stack

defimpl Collectable, for: Stack do
  def into(%Stack{} = stack) do
    {stack, &push/2}
  end

  defp push(stack, {:cont, item}), do: Stack.push(stack, item)
  defp push(stack, :done), do: stack
  defp push(_stack, :halt), do: :ok
end
