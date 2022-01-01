defmodule ExAlgo.Sort.Distribution do
  @moduledoc """
  Distribution Sort
  """
  @type item :: any()
  @type t :: [item()]

  @doc """
  Perform sort by using the pigeonhole_sort algorithm.

  ## Example

      iex> Distribution.pigeonhole_sort([])
      []

      iex> Distribution.pigeonhole_sort([1])
      [1]

      iex> Distribution.pigeonhole_sort([3, 2, 1])
      [1, 2, 3]

      iex> Distribution.pigeonhole_sort([2, 7, -1, 5])
      [-1, 2, 5, 7]

  """
  @spec pigeonhole_sort(t) :: t
  def pigeonhole_sort([]), do: []

  def pigeonhole_sort(xs) do
    {base, max} = Enum.min_max(xs)

    pigeonhole_sort(
      base,
      max - base,
      Enum.reduce(xs, %{}, &Map.update(&2, &1, 1, fn item -> item + 1 end))
    )
  end

  def pigeonhole_sort(base, size, pigeonhole) do
    Enum.reduce(0..size, [], fn x, acc ->
      case pigeonhole[value = base + x] do
        nil ->
          acc

        rep ->
          acc ++
            (Stream.iterate(value, &Function.identity/1)
             |> Enum.take(rep))
      end
    end)
  end
end
